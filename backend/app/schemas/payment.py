from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class PaymentCreate(BaseModel):
    amount: Decimal = Field(gt=0)
    paid_date: date
    period_start: date | None = None  # awal bulan sewa yang dibayar
    note: str | None = None


class PaymentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    tenant_id: int
    amount: Decimal
    paid_date: date
    period_start: date | None
    note: str | None
    created_at: datetime
