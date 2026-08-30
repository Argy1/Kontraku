"""Koneksi ke PostgreSQL.

Isi file:
- `normalize_db_url()` : rapikan URL dari Railway supaya pakai driver psycopg v3.
- `engine`             : "kolam koneksi" ke database (dibuat sekali, dipakai selamanya).
- `SessionLocal`       : pabrik Session — 1 Session = 1 percakapan transaksi ke DB.
- `get_db()`           : dependency FastAPI; buka Session di awal request, tutup di akhir.
"""

from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import settings


def normalize_db_url(url: str) -> str:
    """Railway memberi URL berawalan `postgres://` atau `postgresql://`.
    SQLAlchemy butuh nama driver eksplisit, jadi kita ubah ke `postgresql+psycopg://`
    (psycopg = driver versi 3 yang kita pasang di requirements.txt).
    """
    if url.startswith("postgres://"):
        return "postgresql+psycopg://" + url[len("postgres://") :]
    if url.startswith("postgresql://"):
        return "postgresql+psycopg://" + url[len("postgresql://") :]
    return url


engine = create_engine(
    normalize_db_url(settings.DATABASE_URL),
    pool_pre_ping=True,  # cek koneksi sebelum dipakai; hindari error "connection closed"
    echo=settings.SQL_ECHO,  # set SQL_ECHO=true di .env kalau mau lihat query
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_db() -> Generator[Session, None, None]:
    """Dipakai nanti di endpoint: `def handler(db: Session = Depends(get_db))`."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
