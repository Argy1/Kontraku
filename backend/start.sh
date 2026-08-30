#!/bin/sh
# Jalankan migrasi lalu start server. Dipakai container (Railway).
set -e

echo "==> alembic upgrade head"
alembic upgrade head

echo "==> start uvicorn di port ${PORT:-8000}"
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:-8000}"
