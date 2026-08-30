from __future__ import annotations

from decimal import Decimal

from sqlalchemy import ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, pg_enum
from app.models.enums import UnitStatus


class Unit(Base, TimestampMixin):
    """Satu kamar / petak di dalam sebuah kontrakan."""

    __tablename__ = "units"

    id: Mapped[int] = mapped_column(primary_key=True)
    kontrakan_id: Mapped[int] = mapped_column(
        ForeignKey("kontrakan.id", ondelete="CASCADE"), index=True, nullable=False
    )
    name: Mapped[str] = mapped_column(String(80), nullable=False)  # mis. "Kamar 2"

    status: Mapped[UnitStatus] = mapped_column(
        pg_enum(UnitStatus, "unit_status"),
        default=UnitStatus.kosong,             # default di sisi Python
        server_default=UnitStatus.kosong.value,  # default di sisi DB
        nullable=False,
    )

    # Harga sewa per bulan. Numeric(12, 2) = maksimum 9.999.999.999,99.
    price: Mapped[Decimal | None] = mapped_column(Numeric(12, 2))

    kontrakan: Mapped["Kontrakan"] = relationship(back_populates="units")
    tenants: Mapped[list["Tenant"]] = relationship(
        back_populates="unit", cascade="all, delete-orphan", passive_deletes=True
    )
    reminders: Mapped[list["Reminder"]] = relationship(
        back_populates="unit", cascade="all, delete-orphan", passive_deletes=True
    )
