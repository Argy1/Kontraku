from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class TenantCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    phone: str | None = Field(default=None, max_length=30)
    contract_start: date | None = None
    contract_end: date | None = None
    rent_amount: Decimal | None = Field(default=None, ge=0)
    due_day: int | None = Field(default=None, ge=1, le=31)  # tanggal jatuh tempo tiap bulan


class TenantUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    phone: str | None = Field(default=None, max_length=30)
    contract_start: date | None = None
    contract_end: date | None = None
    rent_amount: Decimal | None = Field(default=None, ge=0)
    due_day: int | None = Field(default=None, ge=1, le=31)
    is_active: bool | None = None


class TenantOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    unit_id: int
    name: str
    phone: str | None
    contract_start: date | None
    contract_end: date | None
    rent_amount: Decimal | None
    due_day: int | None
    is_active: bool
    created_at: datetime
