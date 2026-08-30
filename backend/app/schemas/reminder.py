from datetime import date, datetime

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import ReminderStatus, ReminderType


class ReminderCreate(BaseModel):
    """Untuk reminder yang dibuat manual (maintenance / tagihan utilitas).
    Reminder sewa & kontrak dibuat otomatis oleh sistem."""

    unit_id: int
    tenant_id: int | None = None
    type: ReminderType
    due_date: date
    lead_days: int = Field(default=3, ge=0, le=90)
    title: str | None = Field(default=None, max_length=160)


class ReminderUpdate(BaseModel):
    type: ReminderType | None = None
    due_date: date | None = None
    lead_days: int | None = Field(default=None, ge=0, le=90)
    status: ReminderStatus | None = None
    title: str | None = Field(default=None, max_length=160)


class ReminderOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    unit_id: int
    tenant_id: int | None
    type: ReminderType
    due_date: date
    lead_days: int
    status: ReminderStatus
    title: str | None
    created_at: datetime
