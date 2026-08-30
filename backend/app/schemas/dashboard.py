from datetime import date

from pydantic import BaseModel

from app.models.enums import ReminderType
from app.schemas.kontrakan import KontrakanOut


class AttentionItem(BaseModel):
    """Satu baris di kartu "Perlu perhatian" pada beranda."""

    reminder_id: int
    type: ReminderType
    title: str
    due_date: date
    days_left: int  # bisa negatif kalau sudah lewat
    unit_name: str
    kontrakan_name: str


class DashboardOut(BaseModel):
    greeting_name: str
    kontrakan_count: int
    active_reminder_count: int
    attention: list[AttentionItem]
    kontrakan: list[KontrakanOut]
