from __future__ import annotations

from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, pg_enum
from app.models.enums import DocumentType


class Document(Base, TimestampMixin):
    """Berkas yang diunggah ke Cloudinary (KTP, surat kontrak, foto kontrakan, dll).

    Sesuai ERD, dokumen menempel ke KONTRAKAN. `file_url` menyimpan URL hasil
    upload Cloudinary; berkasnya sendiri tidak disimpan di database.
    """

    __tablename__ = "documents"

    id: Mapped[int] = mapped_column(primary_key=True)
    kontrakan_id: Mapped[int] = mapped_column(
        ForeignKey("kontrakan.id", ondelete="CASCADE"), index=True, nullable=False
    )

    file_url: Mapped[str] = mapped_column(String(500), nullable=False)
    type: Mapped[DocumentType] = mapped_column(
        pg_enum(DocumentType, "document_type"), nullable=False
    )
    label: Mapped[str | None] = mapped_column(String(120))  # nama tampilan opsional

    kontrakan: Mapped["Kontrakan"] = relationship(back_populates="documents")
