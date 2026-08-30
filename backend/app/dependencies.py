"""Dependency yang dipakai bersama banyak endpoint.

Konsep FastAPI: fungsi di sini "disuntikkan" ke handler lewat `Depends(...)`.
Yang paling penting:
- `get_current_user` : ambil user dari token JWT di header Authorization.
- `get_owned_*`      : ambil objek DAN pastikan miliknya user yang login
                        (kalau bukan miliknya -> 404, bukan 403, supaya keberadaan
                        data orang lain tidak bocor).
"""

from __future__ import annotations

from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decode_token
from app.models import Kontrakan, Tenant, Unit, User

# tokenUrl hanya untuk tombol "Authorize" di /docs — arahkan ke endpoint login.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

DbSession = Annotated[Session, Depends(get_db)]


def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)], db: DbSession
) -> User:
    credentials_error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token tidak valid atau kadaluarsa",
        headers={"WWW-Authenticate": "Bearer"},
    )
    user_id = decode_token(token, expected_type="access")
    if user_id is None:
        raise credentials_error
    user = db.get(User, user_id)
    if user is None:
        raise credentials_error
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]

_NOT_FOUND = status.HTTP_404_NOT_FOUND


def get_owned_kontrakan(
    kontrakan_id: int, db: DbSession, user: CurrentUser
) -> Kontrakan:
    obj = db.get(Kontrakan, kontrakan_id)
    if obj is None or obj.owner_id != user.id:
        raise HTTPException(_NOT_FOUND, "Kontrakan tidak ditemukan")
    return obj


def get_owned_unit(unit_id: int, db: DbSession, user: CurrentUser) -> Unit:
    obj = db.get(Unit, unit_id)
    if obj is None or obj.kontrakan.owner_id != user.id:
        raise HTTPException(_NOT_FOUND, "Unit tidak ditemukan")
    return obj


def get_owned_tenant(tenant_id: int, db: DbSession, user: CurrentUser) -> Tenant:
    obj = db.get(Tenant, tenant_id)
    if obj is None or obj.unit.kontrakan.owner_id != user.id:
        raise HTTPException(_NOT_FOUND, "Penyewa tidak ditemukan")
    return obj


OwnedKontrakan = Annotated[Kontrakan, Depends(get_owned_kontrakan)]
OwnedUnit = Annotated[Unit, Depends(get_owned_unit)]
OwnedTenant = Annotated[Tenant, Depends(get_owned_tenant)]
