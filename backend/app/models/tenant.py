from __future__ import annotations

from datetime import date
from decimal import Decimal

from sqlalchemy import Date, ForeignKey, Numeric, SmallInteger, String, text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class Tenant(Base, TimestampMixin):
    """Penyewa sebuah unit untuk satu masa sewa.

    Catatan istilah: "tenant" di sini = PENYEWA orang, bukan "tenant" dalam
    arti multi-tenancy (pemisahan data antar akun). Yang terakhir itu `User`.

    Penyewa lama tidak dihapus — cukup set `is_active = False` supaya
    riwayat tetap tersimpan (sesuai brief).
    """

    __tablename__ = "tenants"

    id: Mapped[int] = mapped_column(primary_key=True)
    unit_id: Mapped[int] = mapped_column(
        ForeignKey("units.id", ondelete="CASCADE"), index=True, nullable=False
    )

    name: Mapped[str] = mapped_column(String(120), nullable=False)
    phone: Mapped[str | None] = mapped_column(String(30))

    contract_start: Mapped[date | None] = mapped_column(Date)
    contract_end: Mapped[date | None] = mapped_column(Date)

    # Nominal sewa yang disepakati penyewa ini (bisa beda dari harga default unit).
    rent_amount: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))

    # Tanggal jatuh tempo tiap bulan, disimpan sebagai angka hari (1-31).
    # Alternatif: simpan tanggal penuh; dipilih angka hari karena sifatnya berulang.
    due_day: Mapped[int | None] = mapped_column(SmallInteger)

    is_active: Mapped[bool] = mapped_column(
        nullable=False, default=True, server_default=text("true"), index=True
    )

    unit: Mapped["Unit"] = relationship(back_populates="tenants")
    payments: Mapped[list["Payment"]] = relationship(
        back_populates="tenant", cascade="all, delete-orphan", passive_deletes=True
    )
    # Reminder TIDAK ikut terhapus saat penyewa dihapus (FK-nya SET NULL),
    # jadi tidak pakai cascade delete-orphan di sini.
    reminders: Mapped[list["Reminder"]] = relationship(
        back_populates="tenant", passive_deletes=True
    )
