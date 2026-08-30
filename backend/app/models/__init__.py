"""Titik kumpul semua model.

Meng-import file ini akan memuat SELURUH kelas model, sehingga:
1. `Base.metadata` berisi definisi semua tabel (dibutuhkan Alembic).
2. Referensi antar-relationship berbentuk string (mis. "Kontrakan") bisa diresolusi.

Aturan main: setiap kali menambah file model baru, daftarkan di sini juga.
"""

from app.models.base import Base
from app.models.document import Document
from app.models.kontrakan import Kontrakan
from app.models.payment import Payment
from app.models.reminder import Reminder
from app.models.tenant import Tenant
from app.models.unit import Unit
from app.models.user import User

__all__ = [
    "Base",
    "User",
    "Kontrakan",
    "Unit",
    "Tenant",
    "Payment",
    "Reminder",
    "Document",
]
