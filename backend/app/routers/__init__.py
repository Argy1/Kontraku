"""Kumpulan router. main.py meng-import modul-modul ini dan memanggil
app.include_router(<modul>.router)."""

from app.routers import (
    auth,
    dashboard,
    kontrakan,
    payments,
    reminders,
    tenants,
    units,
)

__all__ = [
    "auth",
    "kontrakan",
    "units",
    "tenants",
    "payments",
    "reminders",
    "dashboard",
]
