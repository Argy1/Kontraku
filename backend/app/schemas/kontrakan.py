from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import DocumentType
from app.schemas.unit import UnitOut


class KontrakanCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    address: str | None = None
    latitude: Decimal | None = Field(default=None, ge=-90, le=90)
    longitude: Decimal | None = Field(default=None, ge=-180, le=180)


class KontrakanUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    address: str | None = None
    latitude: Decimal | None = Field(default=None, ge=-90, le=90)
    longitude: Decimal | None = Field(default=None, ge=-180, le=180)


class DocumentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    kontrakan_id: int
    file_url: str
    type: DocumentType
    label: str | None
    created_at: datetime


class KontrakanOut(BaseModel):
    """Bentuk ringkas untuk daftar. `unit_count` & `occupied_count` dihitung
    di router (bukan kolom di tabel)."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    address: str | None
    latitude: Decimal | None
    longitude: Decimal | None
    created_at: datetime
    unit_count: int = 0
    occupied_count: int = 0


class KontrakanDetailOut(KontrakanOut):
    units: list[UnitOut] = []
    documents: list[DocumentOut] = []
