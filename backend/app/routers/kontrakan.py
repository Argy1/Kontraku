"""Endpoint kontrakan + dokumen/foto yang menempel padanya."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.dependencies import CurrentUser, DbSession, OwnedKontrakan
from app.models import Document, Kontrakan
from app.models.enums import DocumentType, UnitStatus
from app.schemas.kontrakan import (
    DocumentOut,
    KontrakanCreate,
    KontrakanDetailOut,
    KontrakanOut,
    KontrakanUpdate,
)
from app.services import get_storage

router = APIRouter(prefix="/kontrakan", tags=["kontrakan"])


def kontrakan_to_out(k: Kontrakan) -> KontrakanOut:
    """Ubah objek ORM jadi response, sekalian hitung ringkasan unit.
    Catatan: `k.units` harus sudah di-load sebelum dipanggil."""
    units = k.units
    return KontrakanOut(
        id=k.id,
        name=k.name,
        address=k.address,
        latitude=k.latitude,
        longitude=k.longitude,
        created_at=k.created_at,
        unit_count=len(units),
        occupied_count=sum(1 for u in units if u.status == UnitStatus.terisi),
    )


@router.get("", response_model=list[KontrakanOut])
def list_kontrakan(db: DbSession, user: CurrentUser) -> list[KontrakanOut]:
    rows = (
        db.scalars(
            select(Kontrakan)
            .where(Kontrakan.owner_id == user.id)
            .options(selectinload(Kontrakan.units))
            .order_by(Kontrakan.created_at)
        )
        .unique()
        .all()
    )
    return [kontrakan_to_out(k) for k in rows]


@router.post("", response_model=KontrakanOut, status_code=status.HTTP_201_CREATED)
def create_kontrakan(
    payload: KontrakanCreate, db: DbSession, user: CurrentUser
) -> KontrakanOut:
    k = Kontrakan(owner_id=user.id, **payload.model_dump())
    db.add(k)
    db.commit()
    db.refresh(k)
    return kontrakan_to_out(k)


@router.get("/{kontrakan_id}", response_model=KontrakanDetailOut)
def get_kontrakan(kontrakan: OwnedKontrakan, db: DbSession) -> KontrakanDetailOut:
    db.refresh(kontrakan, ["units", "documents"])
    base = kontrakan_to_out(kontrakan)
    return KontrakanDetailOut(
        **base.model_dump(),
        units=sorted(kontrakan.units, key=lambda u: u.name),
        documents=sorted(kontrakan.documents, key=lambda d: d.created_at),
    )


@router.patch("/{kontrakan_id}", response_model=KontrakanOut)
def update_kontrakan(
    payload: KontrakanUpdate, kontrakan: OwnedKontrakan, db: DbSession
) -> KontrakanOut:
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(kontrakan, field, value)
    db.commit()
    db.refresh(kontrakan, ["units"])
    return kontrakan_to_out(kontrakan)


# Catatan: endpoint 204 sengaja TIDAK diberi anotasi return (-> None).
# Dengan `from __future__ import annotations`, "-> None" jadi string lalu
# dievaluasi FastAPI sebagai NoneType dan memicu error "204 must not have a body".
@router.delete("/{kontrakan_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_kontrakan(kontrakan: OwnedKontrakan, db: DbSession):
    db.delete(kontrakan)
    db.commit()


# --- Dokumen & foto -------------------------------------------------------

@router.get("/{kontrakan_id}/documents", response_model=list[DocumentOut])
def list_documents(kontrakan: OwnedKontrakan, db: DbSession) -> list[Document]:
    return db.scalars(
        select(Document)
        .where(Document.kontrakan_id == kontrakan.id)
        .order_by(Document.created_at)
    ).all()


@router.post(
    "/{kontrakan_id}/documents",
    response_model=DocumentOut,
    status_code=status.HTTP_201_CREATED,
)
async def upload_document(
    kontrakan: OwnedKontrakan,
    db: DbSession,
    file: Annotated[UploadFile, File()],
    type: Annotated[DocumentType, Form()] = DocumentType.foto,
    label: Annotated[str | None, Form()] = None,
) -> Document:
    content = await file.read()
    url = get_storage().save(
        content, file.filename or "file", folder=f"kontrakan/{kontrakan.id}"
    )
    doc = Document(kontrakan_id=kontrakan.id, file_url=url, type=type, label=label)
    db.add(doc)
    db.commit()
    db.refresh(doc)
    return doc


@router.delete(
    "/{kontrakan_id}/documents/{document_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_document(
    kontrakan: OwnedKontrakan, document_id: int, db: DbSession
):
    doc = db.get(Document, document_id)
    if doc is None or doc.kontrakan_id != kontrakan.id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Dokumen tidak ditemukan")
    db.delete(doc)
    db.commit()
