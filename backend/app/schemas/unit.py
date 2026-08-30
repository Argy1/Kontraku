from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import UnitStatus


class UnitCreate(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    status: UnitStatus = UnitStatus.kosong
    price: Decimal | None = Field(default=None, ge=0)


class UnitUpdate(BaseModel):
    # semua opsional: klien kirim hanya field yang ingin diubah
    name: str | None = Field(default=None, min_length=1, max_length=80)
    status: UnitStatus | None = None
    price: Decimal | None = Field(default=None, ge=0)


class UnitOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    kontrakan_id: int
    name: str
    status: UnitStatus
    price: Decimal | None
    created_at: datetime
