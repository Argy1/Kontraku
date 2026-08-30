from __future__ import annotations

from decimal import Decimal

from sqlalchemy import ForeignKey, Numeric, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class Kontrakan(Base, TimestampMixin):
    """Satu properti sewa (bisa punya banyak unit/kamar)."""

    __tablename__ = "kontrakan"

    id: Mapped[int] = mapped_column(primary_key=True)

    # ondelete="CASCADE": kalau user dihapus, semua kontrakannya ikut terhapus di DB.
    # index=True: dipakai sering untuk filter "kontrakan milik user X".
    owner_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )

    name: Mapped[str] = mapped_column(String(120), nullable=False)
    address: Mapped[str | None] = mapped_column(Text)

    # Koordinat opsional (pemilik mungkin belum pilih lokasi di peta).
    # Numeric(9, 6): cukup untuk rentang -180.000000..180.000000, presisi ~0.1 m.
    latitude: Mapped[Decimal | None] = mapped_column(Numeric(9, 6))
    longitude: Mapped[Decimal | None] = mapped_column(Numeric(9, 6))

    owner: Mapped["User"] = relationship(back_populates="kontrakan")
    units: Mapped[list["Unit"]] = relationship(
        back_populates="kontrakan", cascade="all, delete-orphan", passive_deletes=True
    )
    documents: Mapped[list["Document"]] = relationship(
        back_populates="kontrakan", cascade="all, delete-orphan", passive_deletes=True
    )
