"""Penyimpanan file (foto kontrakan, dokumen KTP/kontrak).

- LocalStorage   : simpan ke folder di disk, kembalikan URL http://localhost:8000/uploads/...
- CloudinaryStorage : placeholder untuk nanti (butuh CLOUDINARY_URL).

Dipilih otomatis dari settings.STORAGE_BACKEND.
"""

from __future__ import annotations

import secrets
from abc import ABC, abstractmethod
from pathlib import Path

from app.core.config import settings


class Storage(ABC):
    @abstractmethod
    def save(self, data: bytes, filename: str, folder: str = "") -> str:
        """Simpan file, kembalikan URL publik untuk diakses klien."""


class LocalStorage(Storage):
    def __init__(self, base_dir: str, public_base_url: str) -> None:
        self.base_dir = Path(base_dir)
        self.public_base_url = public_base_url.rstrip("/")
        self.base_dir.mkdir(parents=True, exist_ok=True)

    def save(self, data: bytes, filename: str, folder: str = "") -> str:
        # nama acak di depan supaya file tidak saling menimpa
        safe_name = f"{secrets.token_hex(8)}_{Path(filename).name}"
        rel_dir = Path(folder) if folder else Path()
        target_dir = self.base_dir / rel_dir
        target_dir.mkdir(parents=True, exist_ok=True)
        (target_dir / safe_name).write_bytes(data)
        rel_path = (rel_dir / safe_name).as_posix()
        return f"{self.public_base_url}/uploads/{rel_path}"


class CloudinaryStorage(Storage):
    def __init__(self) -> None:
        raise NotImplementedError(
            "CloudinaryStorage belum diimplementasi. Set STORAGE_BACKEND=local "
            "untuk sekarang, atau isi CLOUDINARY_URL lalu lengkapi kelas ini."
        )

    def save(self, data: bytes, filename: str, folder: str = "") -> str:  # pragma: no cover
        raise NotImplementedError


def get_storage() -> Storage:
    if settings.STORAGE_BACKEND == "cloudinary":
        return CloudinaryStorage()
    return LocalStorage(settings.LOCAL_STORAGE_DIR, settings.PUBLIC_BASE_URL)
