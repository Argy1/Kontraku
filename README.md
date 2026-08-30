# Kontraku

Aplikasi reminder & manajemen kontrakan untuk pemilik properti sewa. Dipakai lewat
mobile app (Android/iOS); penyewa tidak punya akses.

## Struktur

```
Kontraku/
├── backend/    FastAPI + PostgreSQL + Alembic  (lihat backend/README.md)
├── mobile/     Flutter (Dart)                  (lihat mobile/README.md)
├── kontraku-project-brief.md   scope fitur, ERD, tech stack
└── design-reference.html       referensi visual 6 layar (palet & layout)
```

## Tech stack

| Bagian | Teknologi |
|---|---|
| Mobile | Flutter (Dart), provider, dio |
| Backend | FastAPI (Python 3.12+), SQLAlchemy 2.0, Alembic |
| Database | PostgreSQL |
| Auth | JWT (email + password) |
| Notifikasi | lokal terjadwal (`flutter_local_notifications`); FCM menyusul |
| Scheduler | APScheduler in-process (refresh reminder harian) |
| Hosting | Railway (backend + database) — dalam proses |

## Menjalankan cepat (lokal)

**Backend**
```bash
cd backend
python -m venv .venv && .venv\Scripts\activate      # Windows
pip install -r requirements.txt
copy .env.example .env
docker compose up -d          # PostgreSQL
alembic upgrade head
python -m app.seed            # data contoh — login budi@email.com / password123
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

**Mobile**
```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<IP-PC>:8000
```

Detail lengkap ada di `backend/README.md` dan `mobile/README.md`.

## Test

```bash
cd backend && pytest          # 20 test
cd mobile && flutter test     # 31 test
```
