"""Adapter untuk layanan luar.

Pola yang dipakai: tiap layanan punya "interface" + minimal 2 implementasi —
satu tiruan untuk lokal, satu asli untuk produksi. Router memanggil interface,
tidak tahu implementasi mana yang aktif. Ganti backend cukup lewat .env.
"""

from app.services.email import get_email_sender
from app.services.push import get_push_sender
from app.services.storage import get_storage

__all__ = ["get_storage", "get_push_sender", "get_email_sender"]
