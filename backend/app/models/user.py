from __future__ import annotations

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class User(Base, TimestampMixin):
    """Pemilik properti. Satu akun = satu "ruang data" terpisah.

    Isolasi antar pemilik dilakukan di level query nanti (selalu
    `WHERE owner_id = user_yang_login`), bukan lewat database terpisah.
    """

    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    email: Mapped[str] = mapped_column(
        String(255), unique=True, index=True, nullable=False
    )
    # Simpan HASH password (mis. bcrypt), tidak pernah password asli.
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)

    # Satu pemilik punya banyak kontrakan. Nama kelas ditulis sebagai string
    # supaya tidak perlu meng-import Kontrakan di sini (hindari import melingkar).
    # SQLAlchemy meresolusinya lewat registry saat semua model sudah dimuat
    # (lihat app/models/__init__.py).
    kontrakan: Mapped[list["Kontrakan"]] = relationship(
        back_populates="owner",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )
