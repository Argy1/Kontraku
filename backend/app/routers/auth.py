"""Endpoint autentikasi: register, login, data diri, lupa/reset password."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy import select

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_reset_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.dependencies import CurrentUser, DbSession
from app.models import User
from app.schemas.auth import (
    ForgotPasswordIn,
    ForgotPasswordOut,
    RegisterIn,
    ResetPasswordIn,
    TokenOut,
)
from app.schemas.common import Message
from app.schemas.user import UserOut
from app.services import get_email_sender

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=TokenOut, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterIn, db: DbSession) -> TokenOut:
    email = payload.email.lower()
    if db.scalar(select(User).where(User.email == email)):
        raise HTTPException(status.HTTP_409_CONFLICT, "Email sudah terdaftar")

    user = User(
        name=payload.name,
        email=email,
        password_hash=hash_password(payload.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return TokenOut(access_token=create_access_token(user.id))


@router.post("/login", response_model=TokenOut)
def login(
    form: Annotated[OAuth2PasswordRequestForm, Depends()], db: DbSession
) -> TokenOut:
    """Login pakai form-data. Isi field `username` dengan EMAIL."""
    user = db.scalar(select(User).where(User.email == form.username.lower()))
    if user is None or not verify_password(form.password, user.password_hash):
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED, "Email atau password salah"
        )
    return TokenOut(access_token=create_access_token(user.id))


@router.get("/me", response_model=UserOut)
def read_me(user: CurrentUser) -> User:
    return user


@router.post("/forgot-password", response_model=ForgotPasswordOut)
def forgot_password(payload: ForgotPasswordIn, db: DbSession) -> ForgotPasswordOut:
    user = db.scalar(select(User).where(User.email == payload.email.lower()))

    reset_token: str | None = None
    if user is not None:
        reset_token = create_reset_token(user.id)
        get_email_sender().send(
            to=user.email,
            subject="Reset password Kontraku",
            body=(
                "Halo,\n\nGunakan token berikut untuk mengatur ulang password:\n\n"
                f"{reset_token}\n\n"
                f"Token berlaku {settings.RESET_TOKEN_EXPIRE_MINUTES} menit."
            ),
        )

    out = ForgotPasswordOut(
        message="Kalau email terdaftar, instruksi reset sudah dikirim."
    )
    # Di development, kembalikan token langsung supaya gampang dites tanpa email asli.
    if settings.is_development:
        out.reset_token = reset_token
    return out


@router.post("/reset-password", response_model=Message)
def reset_password(payload: ResetPasswordIn, db: DbSession) -> Message:
    user_id = decode_token(payload.token, expected_type="reset")
    user = db.get(User, user_id) if user_id is not None else None
    if user is None:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "Token reset tidak valid atau kadaluarsa"
        )
    user.password_hash = hash_password(payload.new_password)
    db.commit()
    return Message(message="Password berhasil diubah.")
