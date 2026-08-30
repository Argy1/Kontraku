"""Endpoint beranda: satu panggilan berisi semua ringkasan yang dibutuhkan
layar Beranda di aplikasi."""

from __future__ import annotations

from datetime import date

from fastapi import APIRouter
from sqlalchemy import func, select
from sqlalchemy.orm import selectinload

from app.dependencies import CurrentUser, DbSession
from app.models import Kontrakan, Reminder, Unit
from app.models.enums import ReminderStatus
from app.routers.kontrakan import kontrakan_to_out
from app.schemas.dashboard import AttentionItem, DashboardOut

router = APIRouter(tags=["dashboard"])

_ACTIVE_STATUSES = [ReminderStatus.pending, ReminderStatus.sent]
_ATTENTION_LIMIT = 5


@router.get("/dashboard", response_model=DashboardOut)
def get_dashboard(db: DbSession, user: CurrentUser) -> DashboardOut:
    kontrakan_rows = (
        db.scalars(
            select(Kontrakan)
            .where(Kontrakan.owner_id == user.id)
            .options(selectinload(Kontrakan.units))
            .order_by(Kontrakan.created_at)
        )
        .unique()
        .all()
    )

    active_reminder_count = db.scalar(
        select(func.count(Reminder.id))
        .join(Unit, Reminder.unit_id == Unit.id)
        .join(Kontrakan, Unit.kontrakan_id == Kontrakan.id)
        .where(
            Kontrakan.owner_id == user.id,
            Reminder.status.in_(_ACTIVE_STATUSES),
        )
    )

    attention_rows = db.execute(
        select(Reminder, Unit.name, Kontrakan.name)
        .join(Unit, Reminder.unit_id == Unit.id)
        .join(Kontrakan, Unit.kontrakan_id == Kontrakan.id)
        .where(
            Kontrakan.owner_id == user.id,
            Reminder.status.in_(_ACTIVE_STATUSES),
        )
        .order_by(Reminder.due_date)
        .limit(_ATTENTION_LIMIT)
    ).all()

    today = date.today()
    attention = [
        AttentionItem(
            reminder_id=reminder.id,
            type=reminder.type,
            title=reminder.title or reminder.type.value.replace("_", " ").capitalize(),
            due_date=reminder.due_date,
            days_left=(reminder.due_date - today).days,
            unit_name=unit_name,
            kontrakan_name=kontrakan_name,
        )
        for reminder, unit_name, kontrakan_name in attention_rows
    ]

    return DashboardOut(
        greeting_name=user.name,
        kontrakan_count=len(kontrakan_rows),
        active_reminder_count=active_reminder_count or 0,
        attention=attention,
        kontrakan=[kontrakan_to_out(k) for k in kontrakan_rows],
    )
