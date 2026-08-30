"""Setup pytest.

Strategi:
- Pakai database terpisah `kontraku_test` (dibuat otomatis) supaya data asli aman.
- Tiap test jalan di dalam transaksi yang di-rollback di akhir -> DB selalu bersih,
  test tidak saling mempengaruhi, dan cepat (tidak perlu drop/create tabel tiap kali).
"""

from __future__ import annotations

import os

os.environ.setdefault("SCHEDULER_ENABLED", "false")  # jangan start cron di test

from collections.abc import Iterator  # noqa: E402

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402
from sqlalchemy import create_engine, text  # noqa: E402
from sqlalchemy.engine import Engine  # noqa: E402
from sqlalchemy.orm import Session  # noqa: E402

from app.core.config import settings  # noqa: E402
from app.core.database import get_db, normalize_db_url  # noqa: E402
from app.main import app  # noqa: E402
from app.models import Base  # noqa: E402

TEST_DB_NAME = "kontraku_test"


@pytest.fixture(scope="session")
def test_engine() -> Iterator[Engine]:
    base_url = normalize_db_url(settings.DATABASE_URL)
    server_url, _, _ = base_url.rpartition("/")

    # 1. buat database test kalau belum ada (butuh koneksi ke DB "postgres")
    admin = create_engine(f"{server_url}/postgres", isolation_level="AUTOCOMMIT")
    with admin.connect() as conn:
        exists = conn.execute(
            text("SELECT 1 FROM pg_database WHERE datname = :name"),
            {"name": TEST_DB_NAME},
        ).scalar()
        if not exists:
            conn.execute(text(f'CREATE DATABASE "{TEST_DB_NAME}"'))
    admin.dispose()

    # 2. buat semua tabel di database test
    engine = create_engine(f"{server_url}/{TEST_DB_NAME}")
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()


@pytest.fixture
def db_session(test_engine: Engine) -> Iterator[Session]:
    connection = test_engine.connect()
    transaction = connection.begin()
    # join_transaction_mode="create_savepoint": session.commit() di dalam kode
    # hanya melepas savepoint, bukan commit sungguhan -> rollback di bawah tetap
    # membersihkan semuanya.
    session = Session(bind=connection, join_transaction_mode="create_savepoint")
    try:
        yield session
    finally:
        session.close()
        transaction.rollback()
        connection.close()


@pytest.fixture
def client(db_session: Session) -> Iterator[TestClient]:
    app.dependency_overrides[get_db] = lambda: db_session
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture
def auth_client(client: TestClient) -> TestClient:
    """TestClient yang sudah login sebagai user baru."""
    client.post(
        "/auth/register",
        json={"name": "Tester", "email": "tester@example.com", "password": "password123"},
    )
    resp = client.post(
        "/auth/login",
        data={"username": "tester@example.com", "password": "password123"},
    )
    client.headers["Authorization"] = f"Bearer {resp.json()['access_token']}"
    return client
