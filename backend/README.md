# Kontraku — Backend (FastAPI)

REST API untuk aplikasi reminder & manajemen kontrakan. Klien = Flutter (menyusul).

## Struktur folder

```
backend/
├── app/
│   ├── main.py                 # objek FastAPI, pasang CORS + semua router
│   ├── dependencies.py         # get_current_user, get_owned_* (cek kepemilikan)
│   ├── core/
│   │   ├── config.py           # baca .env (class Settings)
│   │   ├── database.py         # engine, Session, get_db()
│   │   └── security.py         # hash password (bcrypt) + token JWT
│   ├── models/                 # tabel database (SQLAlchemy) — 1 file / tabel
│   ├── schemas/                # bentuk request/response (Pydantic)
│   ├── routers/                # endpoint per fitur
│   │   ├── auth.py             #   /auth/*
│   │   ├── kontrakan.py        #   /kontrakan/*  (+ dokumen/foto)
│   │   ├── units.py            #   /kontrakan/{id}/units, /units/{id}
│   │   ├── tenants.py          #   /units/{id}/tenants, /tenants/{id}
│   │   ├── payments.py         #   /tenants/{id}/payments
│   │   ├── reminders.py        #   /reminders/*
│   │   └── dashboard.py        #   /dashboard
│   ├── services/               # adapter layanan luar (storage, push, email)
│   │   └── reminder_engine.py  # buat reminder otomatis dari data penyewa
│   └── seed.py                 # isi data contoh (mirip mockup desain)
├── alembic/                    # migrasi skema database
├── tests/                      # pytest (DB test terpisah, rollback per test)
├── docker-compose.yml          # PostgreSQL + Adminer untuk lokal
├── requirements.txt
└── .env / .env.example
```

## Setup pertama kali (Windows PowerShell)

```powershell
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env        # nilai default sudah cocok untuk lokal
```

## Menjalankan

```powershell
docker compose up -d               # start PostgreSQL (port host 5433) + Adminer
alembic upgrade head               # buat semua tabel
python -m app.seed                 # (opsional) isi data contoh
uvicorn app.main:app --reload
```

- API & dokumentasi interaktif: <http://127.0.0.1:8000/docs>
- Lihat isi database: <http://localhost:8080> (Adminer — server `db`, user/pass/db `kontraku`)
- Login demo (setelah seed): `budi@email.com` / `password123`

Cara pakai `/docs`: buka endpoint `POST /auth/login`, klik **Try it out**, isi
`username` dengan email + `password`, jalankan. Salin `access_token`, klik tombol
**Authorize** di kanan atas, tempel. Sekarang semua endpoint bisa dicoba.

## Migrasi database

Setiap kali model di `app/models/` berubah:

```powershell
alembic revision --autogenerate -m "deskripsi perubahan"
alembic upgrade head        # terapkan
alembic downgrade -1        # batalkan 1 langkah
alembic check               # cek apakah model & DB sudah sinkron
```

## Test

```powershell
pytest
```

Database `kontraku_test` dibuat otomatis di server Postgres yang sama; tiap test
jalan dalam transaksi yang di-rollback sehingga tidak mengotori data.

## Reminder otomatis & scheduler

`sewa_jatuh_tempo` dan `kontrak_habis` adalah **data turunan** dari penyewa
(`due_day`, `contract_end`) — dikelola `app/services/reminder_engine.py`:

- **Saat penyewa ditambah/diubah/diarsipkan** → endpoint tenant langsung
  memanggil `refresh_reminders_for_user` (tidak perlu sync manual).
- **Tombol sync di app** → `POST /reminders/refresh` (paksa segarkan).
- **Scheduler harian** (`app/services/scheduler.py`, APScheduler in-process,
  default 06:00) → `refresh_all_users`: majukan reminder sewa ke periode
  berikutnya, buang yang tidak lagi valid. Atur lewat `SCHEDULER_*` di `.env`;
  matikan dengan `SCHEDULER_ENABLED=false`.

Reconciliation menjaga reminder sewa yang **sudah lewat tapi masih cocok**
dengan `due_day` (artinya nunggak) — itu tidak dibuang.

> Skala: scheduler jalan di dalam proses uvicorn. Kalau nanti di Railway pakai
> >1 instance, pindah ke Railway Cron / tambah lock.

## Adapter layanan luar

Diatur lewat `.env`. Saat lokal semua pakai mode tiruan:

| Layanan | Env | Mode lokal | Nanti |
|---|---|---|---|
| Upload file | `STORAGE_BACKEND=local` | simpan ke `var/uploads/`, sajikan di `/uploads/...` | `cloudinary` |
| Push notif | `PUSH_BACKEND=log` | cetak ke terminal | `fcm` |
| Email | `EMAIL_BACKEND=console` | cetak ke terminal; token reset juga dikembalikan di response | `smtp` |

## Deploy ke Railway

**Sudah live:** <https://backend-production-675a5.up.railway.app> (`/health`, `/docs`).
Project `kontraku` → service `backend` (auto-deploy dari GitHub `main`, watch
`backend/**`) + `Postgres` + volume `kontraku-uploads` di `/app/var`.
Redeploy otomatis tiap push yang menyentuh `backend/`.

File yang dipakai: `Dockerfile`, `start.sh` (migrasi + uvicorn), `railway.json`,
`.dockerignore`.

**Langkah (kalau setup dari awal lagi):**
1. Railway → New Project → **Deploy from GitHub repo** → pilih `Argy1/Kontraku`.
2. Di service yang dibuat → **Settings → Root Directory** = `backend`
   (Railway otomatis pakai `backend/Dockerfile`).
3. Tambah **Database → PostgreSQL** di project yang sama. Railway otomatis
   membuat variabel `DATABASE_URL` — hubungkan ke service backend (Variables →
   Reference → `Postgres.DATABASE_URL`).
4. Set **Variables** di service backend:
   | Variabel | Nilai |
   |---|---|
   | `ENVIRONMENT` | `production` |
   | `SECRET_KEY` | string acak panjang (mis. `openssl rand -hex 32`) |
   | `SCHEDULER_ENABLED` | `true` |
   | `CORS_ORIGINS` | `*` (klien = mobile, tidak kena CORS) |
   | `PUBLIC_BASE_URL` | URL publik Railway service (untuk link `/uploads/...`) |
5. **Networking → Generate Domain** → dapat URL `https://xxx.up.railway.app`.
6. `start.sh` menjalankan `alembic upgrade head` tiap deploy, jadi skema selalu
   ikut ter-migrasi.

**Setelah deploy:** cek `https://xxx.up.railway.app/health` dan `/docs`. Lalu di
mobile, build ulang dengan `--dart-define=API_BASE_URL=https://xxx.up.railway.app`
atau ubah di **Pengaturan server** dalam app.

**Catatan penting:**
- **Upload foto** (`STORAGE_BACKEND=local`) tersimpan di disk container yang
  *ephemeral* — hilang tiap redeploy. Untuk sementara oke; solusi: tambah
  **Railway Volume** di `/app/var`, atau pindah ke Cloudinary.
- Scheduler jalan in-process. Biarkan `numReplicas: 1` (di `railway.json`) supaya
  cron tidak jalan dobel.

## Catatan

- Python 3.14 (dev) memunculkan `DeprecationWarning` dari dalam FastAPI. Image
  Railway pakai Python 3.12 — tidak ada warning itu.
- Belum ada: endpoint device token FCM, integrasi Google Maps (sisi Flutter).
