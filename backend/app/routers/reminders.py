"""Endpoint reminder.

- GET  /reminders           daftar (dengan filter tipe & status)
- POST /reminders           buat manual (maintenance / utilitas)
- PATCH /reminders/{id}     ubah — paling sering untuk tandai selesai/diabaikan
- DELETE /reminders/{id}
- POST /reminders/refresh   buat ulang reminder otomatis dari data penyewa
"""

from __future__ import annotations

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.dependencies import CurrentUser, DbSession
from app.models import Kontrakan, Reminder, Unit, User
from app.models.enums import ReminderStatus, ReminderType
from app.schemas.common import Message
from app.schemas.reminder import ReminderCreate, ReminderOut, ReminderUpdate
from app.services.reminder_engine import refresh_reminders_for_user

router = APIRouter(prefix="/reminders", tags=["reminders"])


def _get_owned_reminder(reminder_id: int, db: Session, user: User) -> Reminder:
    reminder = db.get(Reminder, reminder_id)
    if reminder is None or reminder.unit.kontrakan.owner_id != user.id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Reminder tidak ditemukan")
    return reminder


@router.get("", response_model=list[ReminderOut])
def list_reminders(
    db: DbSession,
    user: CurrentUser,
    type: ReminderType | None = Query(default=None, description="Filter satu tipe"),
    status_: ReminderStatus | None = Query(
        default=None, alias="status", description="Filter satu status"
    ),
    include_done: bool = Query(
        default=False, description="Ikutkan yang sudah selesai/diabaikan"
    ),
) -> list[Reminder]:
    stmt = (
        select(Reminder)
        .join(Unit, Reminder.unit_id == Unit.id)
        .join(Kontrakan, Unit.kontrakan_id == Kontrakan.id)
        .where(Kontrakan.owner_id == user.id)
    )
    if type is not None:
        stmt = stmt.where(Reminder.type == type)
    if status_ is not None:
        stmt = stmt.where(Reminder.status == status_)
    elif not include_done:
        stmt = stmt.where(
            Reminder.status.in_([ReminderStatus.pending, ReminderStatus.sent])
        )
    return db.scalars(stmt.order_by(Reminder.due_date)).all()


@router.post("", response_model=ReminderOut, status_code=status.HTTP_201_CREATED)
def create_reminder(
    payload: ReminderCreate, db: DbSession, user: CurrentUser
) -> Reminder:
    unit = db.get(Unit, payload.unit_id)
    if unit is None or unit.kontrakan.owner_id != user.id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Unit tidak ditemukan")
    if payload.tenant_id is not None:
        valid_tenant = any(t.id == payload.tenant_id for t in unit.tenants)
        if not valid_tenant:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "tenant_id bukan penyewa dari unit ini",
            )

    reminder = Reminder(**payload.model_dump())
    db.add(reminder)
    db.commit()
    db.refresh(reminder)
    return reminder


@router.patch("/{reminder_id}", response_model=ReminderOut)
def update_reminder(
    reminder_id: int, payload: ReminderUpdate, db: DbSession, user: CurrentUser
) -> Reminder:
    reminder = _get_owned_reminder(reminder_id, db, user)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(reminder, field, value)
    db.commit()
    db.refresh(reminder)
    return reminder


@router.delete("/{reminder_id}", response_model=Message)
def delete_reminder(
    reminder_id: int, db: DbSession, user: CurrentUser
) -> Message:
    reminder = _get_owned_reminder(reminder_id, db, user)
    db.delete(reminder)
    db.commit()
    return Message(message="Reminder dihapus.")


@router.post("/refresh", response_model=Message)
def refresh_reminders(db: DbSession, user: CurrentUser) -> Message:
    result = refresh_reminders_for_user(db, user)
    return Message(
        message=f"{result.created} reminder baru, {result.dismissed} dibersihkan."
    )
