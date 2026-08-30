"""Fungsi keamanan: hash password & token JWT.

Dipisah dari router supaya gampang dites dan dipakai ulang.
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import bcrypt
import jwt

from app.core.config import settings


# --- Password ---------------------------------------------------------------

def hash_password(plain: str) -> str:
    """Ubah password asli jadi hash bcrypt (aman disimpan di DB)."""
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str) -> bool:
    """Cek apakah password yang diketik cocok dengan hash tersimpan."""
    try:
        return bcrypt.checkpw(plain.encode(), hashed.encode())
    except ValueError:
        return False


# --- JWT -------------------------------------------------------------------

def _create_token(subject: str, expires_minutes: int, token_type: str) -> str:
    now = datetime.now(UTC)
    payload = {
        "sub": subject,               # id user, sebagai string
        "type": token_type,           # "access" atau "reset"
        "iat": now,
        "exp": now + timedelta(minutes=expires_minutes),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def create_access_token(user_id: int) -> str:
    return _create_token(str(user_id), settings.ACCESS_TOKEN_EXPIRE_MINUTES, "access")


def create_reset_token(user_id: int) -> str:
    return _create_token(str(user_id), settings.RESET_TOKEN_EXPIRE_MINUTES, "reset")


def decode_token(token: str, expected_type: str) -> int | None:
    """Kembalikan user_id kalau token valid & tipenya benar, selain itu None."""
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.JWT_ALGORITHM]
        )
    except jwt.PyJWTError:
        return None
    if payload.get("type") != expected_type:
        return None
    sub = payload.get("sub")
    return int(sub) if sub is not None else None
