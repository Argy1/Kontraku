"""Isi database dengan data contoh (mirip mockup desain).

Jalankan:  python -m app.seed
Ulangi dari awal:  python -m app.seed --reset   (hapus data user demo dulu)

Login demo:  email  budi@email.com   password  password123
"""

from __future__ import annotations

import sys
from datetime import date, timedelta
from decimal import Decimal

from sqlalchemy import select

from app.core.database import SessionLocal
from app.core.security import hash_password
from app.models import Kontrakan, Payment, Reminder, Tenant, Unit, User
from app.models.enums import ReminderType, UnitStatus
from app.services.reminder_engine import refresh_reminders_for_user

DEMO_EMAIL = "budi@email.com"
DEMO_PASSWORD = "password123"


def _wipe_demo(db) -> None:
    user = db.scalar(select(User).where(User.email == DEMO_EMAIL))
    if user is not None:
        db.delete(user)  # cascade menghapus kontrakan, unit, penyewa, dst
        db.commit()
        print("Data demo lama dihapus.")


def seed() -> None:
    today = date.today()
    db = SessionLocal()
    try:
        if db.scalar(select(User).where(User.email == DEMO_EMAIL)):
            print(
                f"User demo sudah ada ({DEMO_EMAIL}). "
                "Jalankan `python -m app.seed --reset` untuk mengisi ulang."
            )
            return

        user = User(
            name="Pak Budi",
            email=DEMO_EMAIL,
            password_hash=hash_password(DEMO_PASSWORD),
        )
        db.add(user)
        db.flush()  # supaya user.id terisi

        melati = Kontrakan(
            owner_id=user.id,
            name="Kontrakan melati",
            address="Jl. mawar no. 5, bogor",
            latitude=Decimal("-6.595038"),
            longitude=Decimal("106.816635"),
        )
        anggrek = Kontrakan(
            owner_id=user.id,
            name="Kontrakan anggrek",
            address="Jl. kenanga no. 12, bogor",
        )
        db.add_all([melati, anggrek])
        db.flush()

        # --- unit melati ---
        m1 = Unit(kontrakan_id=melati.id, name="Kamar 1", status=UnitStatus.terisi, price=Decimal("800000"))
        m2 = Unit(kontrakan_id=melati.id, name="Kamar 2", status=UnitStatus.terisi, price=Decimal("850000"))
        m3 = Unit(kontrakan_id=melati.id, name="Kamar 3", status=UnitStatus.kosong, price=Decimal("800000"))
        m4 = Unit(kontrakan_id=melati.id, name="Kamar 4", status=UnitStatus.terisi, price=Decimal("750000"))
        # --- unit anggrek ---
        a1 = Unit(kontrakan_id=anggrek.id, name="Kamar 1", status=UnitStatus.terisi, price=Decimal("900000"))
        a2 = Unit(kontrakan_id=anggrek.id, name="Kamar 2", status=UnitStatus.kosong, price=Decimal("900000"))
        a3 = Unit(kontrakan_id=anggrek.id, name="Kamar 3", status=UnitStatus.renovasi, price=Decimal("950000"))
        db.add_all([m1, m2, m3, m4, a1, a2, a3])
        db.flush()

        joko = Tenant(
            unit_id=m1.id, name="Pak Joko", phone="0812-1111-2222",
            contract_start=today - timedelta(days=300),
            contract_end=today + timedelta(days=10),   # -> reminder "kontrak akan habis"
            rent_amount=Decimal("800000"), due_day=5,
        )
        sari = Tenant(
            unit_id=m2.id, name="Bu Sari", phone="0813-3333-4444",
            contract_start=today - timedelta(days=120),
            contract_end=today + timedelta(days=200),
            rent_amount=Decimal("850000"),
            due_day=(today + timedelta(days=3)).day,   # -> reminder "sewa jatuh tempo" ~3 hari
        )
        agus = Tenant(
            unit_id=m4.id, name="Pak Agus", phone="0814-5555-6666",
            contract_start=today - timedelta(days=60),
            contract_end=today + timedelta(days=305),
            rent_amount=Decimal("750000"), due_day=20,
        )
        anto = Tenant(
            unit_id=a1.id, name="Pak Anto", phone="0815-7777-8888",
            contract_start=today - timedelta(days=365),
            contract_end=today,                         # -> kontrak habis "hari ini"
            rent_amount=Decimal("900000"), due_day=1,
        )
        # penyewa lama yang sudah diarsipkan
        old = Tenant(
            unit_id=m1.id, name="Bu Rina (lama)", phone="0816-9999-0000",
            contract_start=today - timedelta(days=730),
            contract_end=today - timedelta(days=320),
            rent_amount=Decimal("750000"), is_active=False,
        )
        db.add_all([joko, sari, agus, anto, old])
        db.flush()

        db.add_all([
            Payment(tenant_id=joko.id, amount=Decimal("800000"),
                    paid_date=today - timedelta(days=25),
                    period_start=(today - timedelta(days=25)).replace(day=1)),
            Payment(tenant_id=agus.id, amount=Decimal("750000"),
                    paid_date=today - timedelta(days=8),
                    period_start=today.replace(day=1)),
        ])

        # reminder manual (tipe maintenance) — otomatis di-generate hanya sewa & kontrak
        db.add(Reminder(
            unit_id=m4.id, tenant_id=None, type=ReminderType.maintenance,
            due_date=today + timedelta(days=5), title="Cek AC - Kamar 4",
        ))

        db.commit()

        result = refresh_reminders_for_user(db, user)
        print(f"Seed selesai. Reminder otomatis dibuat: {result.created}.")
        print(f"Login: {DEMO_EMAIL} / {DEMO_PASSWORD}")
    finally:
        db.close()


if __name__ == "__main__":
    with SessionLocal() as _db:
        if "--reset" in sys.argv:
            _wipe_demo(_db)
    seed()
