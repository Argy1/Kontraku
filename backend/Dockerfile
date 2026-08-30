# Image untuk deploy backend (Railway pakai ini).
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# install dependency dulu (layer cache: tidak re-install kalau cuma kode berubah)
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
RUN chmod +x start.sh

# Railway meng-inject $PORT
ENV PORT=8000
EXPOSE 8000

CMD ["./start.sh"]
