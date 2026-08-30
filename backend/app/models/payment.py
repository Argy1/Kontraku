from __future__ import annotations

from datetime import date
from decimal import Decimal

from sqlalchemy import Date, ForeignKey, Numeric, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class Payment(Base, TimestampMixin):
    """Satu catatan pembayaran dari seorang penyewa untuk satu periode."""

    __tablename__ = "payments"

    id: Mapped[int] = mapped_column(primary_key=True)
    tenant_id: Mapped[int] = mapped_column(
        ForeignKey("tenants.id", ondelete="CASCADE"), index=True, nullable=False
    )

    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    paid_date: Mapped[date] = mapped_column(Date, nullable=False)

    # Awal periode sewa yang dilunasi pembayaran ini (mis. 2026-08-01).
    # Berguna untuk tahu bulan mana yang sudah/belum dibayar.
    period_start: Mapped[date | None] = mapped_column(Date)

    note: Mapped[str | None] = mapped_column(Text)

    tenant: Mapped["Tenant"] = relationship(back_populates="payments")
