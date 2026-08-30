"""Titik masuk aplikasi FastAPI.

Jalankan: uvicorn app.main:app --reload
Dokumentasi interaktif: http://127.0.0.1:8000/docs
"""

from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.routers import auth, dashboard, kontrakan, payments, reminders, tenants, units
from app.services.scheduler import start_scheduler, stop_scheduler


@asynccontextmanager
async def lifespan(_: FastAPI):
    start_scheduler()  # cron harian penyegar reminder
    yield
    stop_scheduler()


app = FastAPI(
    title="Kontraku API",
    version="0.1.0",
    description="Backend reminder & manajemen kontrakan untuk pemilik properti sewa.",
    lifespan=lifespan,
)

# --- CORS: siapa yang boleh memanggil API dari browser ---
# Wildcard "*" tidak boleh digabung dengan allow_credentials=True (aturan browser),
# jadi kredensial dimatikan otomatis kalau origin-nya "*".
_allow_all = "*" in settings.cors_origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=not _allow_all,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- File upload lokal: sajikan folder uploads di /uploads/... ---
if settings.STORAGE_BACKEND == "local":
    upload_dir = Path(settings.LOCAL_STORAGE_DIR)
    upload_dir.mkdir(parents=True, exist_ok=True)
    app.mount("/uploads", StaticFiles(directory=upload_dir), name="uploads")

# --- Daftarkan semua router ---
app.include_router(auth.router)
app.include_router(kontrakan.router)
app.include_router(units.router)
app.include_router(tenants.router)
app.include_router(payments.router)
app.include_router(reminders.router)
app.include_router(dashboard.router)


@app.get("/health", tags=["meta"])
def health_check() -> dict[str, str]:
    return {"status": "ok", "environment": settings.ENVIRONMENT}
