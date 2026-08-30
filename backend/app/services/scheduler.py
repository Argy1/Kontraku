"""Scheduler cron di dalam proses (APScheduler).

Sekali sehari (default 06:00) menjalankan `refresh_all_users`:
- membuat reminder `sewa_jatuh_tempo` / `kontrak_habis` yang seharusnya ada
- memajukan reminder sewa ke periode berikutnya setelah tanggal jatuh tempo lewat
- membersihkan reminder yang tidak lagi valid

Catatan skala: ini jalan di dalam proses uvicorn. Kalau nanti di Railway pakai
>1 instance, pindahkan ke Railway Cron atau tambah lock supaya tidak dobel jalan.
"""

from __future__ import annotations

import logging

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger

from app.core.config import settings
from app.core.database import SessionLocal
from app.services.reminder_engine import refresh_all_users

logger = logging.getLogger("kontraku.scheduler")

_scheduler: BackgroundScheduler | None = None


def _job() -> None:
    db = SessionLocal()
    try:
        refresh_all_users(db)
    except Exception:  # noqa: BLE001 - jangan sampai job mematikan scheduler
        logger.exception("job refresh reminder harian gagal")
    finally:
        db.close()


def start_scheduler() -> None:
    global _scheduler
    if not settings.SCHEDULER_ENABLED or _scheduler is not None:
        return

    _scheduler = BackgroundScheduler(timezone="Asia/Jakarta")
    _scheduler.add_job(
        _job,
        CronTrigger(hour=settings.SCHEDULER_HOUR, minute=settings.SCHEDULER_MINUTE),
        id="daily_reminder_refresh",
        replace_existing=True,
        misfire_grace_time=3600,  # kalau server sempat mati, masih boleh telat 1 jam
    )
    _scheduler.start()
    logger.info(
        "scheduler aktif — refresh reminder tiap hari %02d:%02d",
        settings.SCHEDULER_HOUR,
        settings.SCHEDULER_MINUTE,
    )


def stop_scheduler() -> None:
    global _scheduler
    if _scheduler is not None:
        _scheduler.shutdown(wait=False)
        _scheduler = None


def run_now() -> None:
    """Jalankan job sekali sekarang (dipakai manual / saat start di dev)."""
    _job()
