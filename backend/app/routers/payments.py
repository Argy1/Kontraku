"""Endpoint log pembayaran per penyewa."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from app.dependencies import CurrentUser, DbSession, OwnedTenant
from app.models import Kontrakan, Payment, Tenant, Unit
from app.schemas.common import Message
from app.schemas.payment import PaymentCreate, PaymentOut

router = APIRouter(tags=["payments"])


@router.get("/tenants/{tenant_id}/payments", response_model=list[PaymentOut])
def list_payments(tenant: OwnedTenant, db: DbSession) -> list[Payment]:
    return db.scalars(
        select(Payment)
        .where(Payment.tenant_id == tenant.id)
        .order_by(Payment.paid_date.desc())
    ).all()


@router.post(
    "/tenants/{tenant_id}/payments",
    response_model=PaymentOut,
    status_code=status.HTTP_201_CREATED,
)
def create_payment(
    payload: PaymentCreate, tenant: OwnedTenant, db: DbSession
) -> Payment:
    payment = Payment(tenant_id=tenant.id, **payload.model_dump())
    db.add(payment)
    db.commit()
    db.refresh(payment)
    return payment


@router.delete("/payments/{payment_id}", response_model=Message)
def delete_payment(
    payment_id: int, db: DbSession, user: CurrentUser
) -> Message:
    payment = db.get(Payment, payment_id)
    # pastikan pembayaran ini ada di jalur kepemilikan user
    owner_id = (
        db.scalar(
            select(Kontrakan.owner_id)
            .join(Unit, Unit.kontrakan_id == Kontrakan.id)
            .join(Tenant, Tenant.unit_id == Unit.id)
            .where(Tenant.id == payment.tenant_id)
        )
        if payment is not None
        else None
    )
    if payment is None or owner_id != user.id:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND, "Pembayaran tidak ditemukan"
        )
    db.delete(payment)
    db.commit()
    return Message(message="Pembayaran dihapus.")
