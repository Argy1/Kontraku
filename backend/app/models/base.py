"""Fondasi semua model database."""

from datetime import datetime

from sqlalchemy import DateTime, Enum, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    """Kelas induk semua tabel.

    `Base.metadata` menampung daftar seluruh tabel — dipakai Alembic untuk
    membandingkan model dengan skema database saat membuat migrasi.
    """


class TimestampMixin:
    """Kolom `created_at` & `updated_at` yang dipakai ulang di banyak tabel.

    Nilai diisi oleh database (server_default = func.now()), bukan oleh Python,
    jadi tetap konsisten walau datanya dimasukkan dari mana saja.
    """

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )


def pg_enum(enum_cls: type, name: str) -> Enum:
    """Bikin tipe ENUM asli PostgreSQL.

    `values_callable` memaksa yang disimpan di DB adalah `.value` string
    (mis. "kosong"), bukan nama anggota Python. Lebih aman kalau nanti
    nama variabel di kode berubah.
    """
    return Enum(
        enum_cls,
        name=name,
        values_callable=lambda cls: [member.value for member in cls],
    )
