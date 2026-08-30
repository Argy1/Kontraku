from pydantic import BaseModel, EmailStr, Field


class RegisterIn(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"


class ForgotPasswordIn(BaseModel):
    email: EmailStr


class ForgotPasswordOut(BaseModel):
    message: str
    # Hanya diisi saat ENVIRONMENT=development supaya bisa dites tanpa email asli.
    reset_token: str | None = None


class ResetPasswordIn(BaseModel):
    token: str
    new_password: str = Field(min_length=6, max_length=128)
