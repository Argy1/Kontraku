"""Konfigurasi aplikasi.

Semua nilai dibaca dari environment variable / file .env lewat pydantic-settings.
Keuntungan: tidak ada rahasia (password DB, secret key) yang ditulis di kode,
dan mudah ganti nilai antara laptop kamu vs server Railway.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",  # abaikan env var lain yang tidak dikenal
    )

    # --- Database ---
    # Default menunjuk Postgres lokal (docker-compose.yml). Di Railway di-override
    # otomatis oleh variabel DATABASE_URL milik service.
    DATABASE_URL: str = "postgresql://kontraku:kontraku@localhost:5432/kontraku"

    # --- Auth (JWT) ---
    SECRET_KEY: str = "dev-secret-change-me"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24
    JWT_ALGORITHM: str = "HS256"
    RESET_TOKEN_EXPIRE_MINUTES: int = 30

    # --- Umum ---
    ENVIRONMENT: str = "development"
    SQL_ECHO: bool = False  # kalau True, semua query SQL dicetak ke terminal
    # Daftar origin dipisah koma di .env (mis. "http://localhost:3000,https://app.contoh.com").
    # "*" berarti semua origin. Dibaca sebagai list lewat properti `cors_origins`.
    CORS_ORIGINS: str = "*"

    # --- Adapter layanan luar ---
    STORAGE_BACKEND: str = "local"          # local | cloudinary
    LOCAL_STORAGE_DIR: str = "./var/uploads"
    PUBLIC_BASE_URL: str = "http://localhost:8000"
    PUSH_BACKEND: str = "log"               # log | fcm
    EMAIL_BACKEND: str = "console"          # console | smtp

    # --- Scheduler (cron harian penyegar reminder) ---
    SCHEDULER_ENABLED: bool = True
    SCHEDULER_HOUR: int = 6                 # jam 06:00 (sebelum jam notif default 08:00)
    SCHEDULER_MINUTE: int = 0

    @property
    def cors_origins(self) -> list[str]:
        return [item.strip() for item in self.CORS_ORIGINS.split(",") if item.strip()]

    @property
    def is_development(self) -> bool:
        return self.ENVIRONMENT.lower() == "development"


# Satu instance dipakai bersama di seluruh aplikasi.
settings = Settings()
