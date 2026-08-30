from __future__ import annotations

from datetime import date

from sqlalchemy import Date, ForeignKey, SmallInteger, String, text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, pg_enum
from app.models.enums import ReminderStatus, ReminderType


class Reminder(Base, TimestampMixin):
    """Satu pengingat yang muncul di beranda & dikirim lewat FCM.

    - `unit_id` wajib: setiap reminder selalu menempel ke sebuah unit.
    - `tenant_id` opsional: reminder "maintenance" / "utilitas" bisa tanpa penyewa.
      Kalau penyewa dihapus, kolom ini di-set NULL (reminder tetap ada).
    """

    __tablename__ = "reminders"

    id: Mapped[int] = mapped_column(primary_key=True)
    unit_id: Mapped[int] = mapped_column(
        ForeignKey("units.id", ondelete="CASCADE"), index=True, nullable=False
    )
    tenant_id: Mapped[int | None] = mapped_column(
        ForeignKey("tenants.id", ondelete="SET NULL"), index=True
    )

    type: Mapped[ReminderType] = mapped_column(
        pg_enum(ReminderType, "reminder_type"), nullable=False
    )
    due_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)

    # Mulai kirim notifikasi H-berapa hari sebelum due_date.
    lead_days: Mapped[int] = mapped_column(
        SmallInteger, nullable=False, default=3, server_default=text("3")
    )

    status: Mapped[ReminderStatus] = mapped_column(
        pg_enum(ReminderStatus, "reminder_status"),
        nullable=False,
        default=ReminderStatus.pending,
        server_default=ReminderStatus.pending.value,
    )

    # Teks bebas untuk ditampilkan (mis. "Cek AC - kamar 4").
    title: Mapped[str | None] = mapped_column(String(160))

    unit: Mapped["Unit"] = relationship(back_populates="reminders")
    tenant: Mapped["Tenant"] = relationship(back_populates="reminders")
