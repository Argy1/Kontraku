"""Membuat & menjaga reminder otomatis dari data penyewa.

Dua tipe dibuat otomatis:
- `kontrak_habis`      : dari Tenant.contract_end
- `sewa_jatuh_tempo`   : dari Tenant.due_day (tanggal jatuh tempo tiap bulan)

Tipe `maintenance` & `utilitas` TIDAK disentuh di sini — itu manual.

`refresh_reminders_for_user` memperlakukan reminder otomatis sebagai DATA TURUNAN:
- yang seharusnya ada tapi belum -> dibuat
- yang tidak lagi valid (penyewa diarsipkan, due_day/contract_end berubah) ->
  di-`dismissed` (bukan dihapus, biar riwayat tetap ada)
- yang sudah lewat tapi masih valid & belum ditandai lunas -> DIBIARKAN
  (itu artinya "sewa nunggak / kontrak lewat", justru harus terlihat)

Idempoten: aman dipanggil berkali-kali (mis. tiap hari oleh scheduler).
"""

from __future__ import annotations

import calendar
import logging
from dataclasses import dataclass
from datetime import date, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import Kontrakan, Reminder, Tenant, Unit, User
from app.models.enums import ReminderStatus, ReminderType

logger = logging.getLogger("kontraku.reminders")

# Reminder dibuat hanya kalau jatuh temponya dalam rentang ini ke depan.
DEFAULT_HORIZON_DAYS = 60

_AUTO_TYPES = (ReminderType.sewa_jatuh_tempo, ReminderType.kontrak_habis)
_ACTIVE_STATUSES = (ReminderStatus.pending, ReminderStatus.sent)


@dataclass
class RefreshResult:
    created: int = 0
    dismissed: int = 0

    def __add__(self, other: "RefreshResult") -> "RefreshResult":
        return RefreshResult(
            self.created + other.created, self.dismissed + other.dismissed
        )


def _clamp_day(year: int, month: int, day: int) -> date:
    """Amankan tanggal 31 untuk bulan yang cuma 30/28 hari."""
    last_day = calendar.monthrange(year, month)[1]
    return date(year, month, min(day, last_day))


def _next_due_date(today: date, due_day: int) -> date:
    """Tanggal jatuh tempo terdekat yang belum lewat."""
    this_month = _clamp_day(today.year, today.month, due_day)
    if this_month >= today:
        return this_month
    next_year, next_month = today.year, today.month + 1
    if next_month == 13:
        next_year, next_month = next_year + 1, 1
    return _clamp_day(next_year, next_month, due_day)


def _is_valid_rent_date(reminder_date: date, due_day: int) -> bool:
    """True kalau `reminder_date` benar-benar salah satu kemunculan `due_day`."""
    return reminder_date == _clamp_day(
        reminder_date.year, reminder_date.month, due_day
    )


def _ensure_reminder(
    db: Session,
    *,
    unit_id: int,
    tenant_id: int | None,
    rtype: ReminderType,
    due_date: date,
    title: str,
) -> bool:
    """Buat reminder kalau belum ada (status apa pun). True kalau baru dibuat."""
    existing = db.scalar(
        select(Reminder).where(
            Reminder.unit_id == unit_id,
            Reminder.tenant_id == tenant_id,
            Reminder.type == rtype,
            Reminder.due_date == due_date,
        )
    )
    if existing is not None:
        return False
    db.add(
        Reminder(
            unit_id=unit_id,
            tenant_id=tenant_id,
            type=rtype,
            due_date=due_date,
            title=title,
            status=ReminderStatus.pending,
        )
    )
    return True


def refresh_reminders_for_user(
    db: Session, user: User, *, horizon_days: int = DEFAULT_HORIZON_DAYS
) -> RefreshResult:
    """Segarkan reminder otomatis untuk semua penyewa milik `user`."""
    today = date.today()
    horizon = today + timedelta(days=horizon_days)

    # semua penyewa milik user (aktif & non-aktif) untuk validasi
    all_tenants = {
        t.id: t
        for t in db.scalars(
            select(Tenant)
            .join(Unit, Tenant.unit_id == Unit.id)
            .join(Kontrakan, Unit.kontrakan_id == Kontrakan.id)
            .where(Kontrakan.owner_id == user.id)
        ).unique()
    }

    result = RefreshResult()

    # --- 1. buang reminder otomatis yang tidak lagi valid ---
    auto_reminders = db.scalars(
        select(Reminder)
        .join(Unit, Reminder.unit_id == Unit.id)
        .join(Kontrakan, Unit.kontrakan_id == Kontrakan.id)
        .where(
            Kontrakan.owner_id == user.id,
            Reminder.type.in_(_AUTO_TYPES),
            Reminder.status.in_(_ACTIVE_STATUSES),
        )
    ).unique().all()

    for r in auto_reminders:
        tenant = all_tenants.get(r.tenant_id)
        valid = tenant is not None and tenant.is_active
        if valid and r.type == ReminderType.sewa_jatuh_tempo:
            valid = bool(tenant.due_day) and _is_valid_rent_date(
                r.due_date, tenant.due_day
            )
        elif valid and r.type == ReminderType.kontrak_habis:
            valid = tenant.contract_end == r.due_date

        if not valid:
            r.status = ReminderStatus.dismissed
            result.dismissed += 1

    # --- 2. pastikan reminder yang seharusnya ada, ada ---
    for tenant in all_tenants.values():
        if not tenant.is_active:
            continue
        unit_name = tenant.unit.name

        if tenant.contract_end and today <= tenant.contract_end <= horizon:
            if _ensure_reminder(
                db,
                unit_id=tenant.unit_id,
                tenant_id=tenant.id,
                rtype=ReminderType.kontrak_habis,
                due_date=tenant.contract_end,
                title=f"Kontrak akan habis - {unit_name}",
            ):
                result.created += 1

        if tenant.due_day:
            due = _next_due_date(today, tenant.due_day)
            if due <= horizon and _ensure_reminder(
                db,
                unit_id=tenant.unit_id,
                tenant_id=tenant.id,
                rtype=ReminderType.sewa_jatuh_tempo,
                due_date=due,
                title=f"Sewa jatuh tempo - {unit_name}",
            ):
                result.created += 1

    db.commit()
    return result


def refresh_all_users(db: Session) -> RefreshResult:
    """Dipanggil scheduler harian: segarkan reminder untuk SEMUA pemilik."""
    total = RefreshResult()
    for user in db.scalars(select(User)):
        total += refresh_reminders_for_user(db, user)
    logger.info(
        "refresh harian: %d reminder dibuat, %d dibersihkan",
        total.created,
        total.dismissed,
    )
    return total
