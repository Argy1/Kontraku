"""Endpoint penyewa. Penyewa lama diarsipkan (is_active=False), bukan dihapus.

Setiap perubahan penyewa (tambah / ubah / arsip) langsung memicu penyegaran
reminder otomatis, jadi pengguna tidak perlu menekan tombol sync manual.
"""

from __future__ import annotations

from fastapi import APIRouter, Query, status
from sqlalchemy import select

from app.dependencies import CurrentUser, DbSession, OwnedTenant, OwnedUnit
from app.models import Tenant
from app.schemas.common import Message
from app.schemas.tenant import TenantCreate, TenantOut, TenantUpdate
from app.services.reminder_engine import refresh_reminders_for_user

router = APIRouter(tags=["tenants"])


@router.get("/units/{unit_id}/tenants", response_model=list[TenantOut])
def list_tenants(
    unit: OwnedUnit,
    db: DbSession,
    include_inactive: bool = Query(
        default=False, description="Ikutkan penyewa lama yang sudah diarsipkan"
    ),
) -> list[Tenant]:
    stmt = select(Tenant).where(Tenant.unit_id == unit.id)
    if not include_inactive:
        stmt = stmt.where(Tenant.is_active.is_(True))
    return db.scalars(stmt.order_by(Tenant.contract_start.desc())).all()


@router.post(
    "/units/{unit_id}/tenants",
    response_model=TenantOut,
    status_code=status.HTTP_201_CREATED,
)
def create_tenant(
    payload: TenantCreate, unit: OwnedUnit, db: DbSession, user: CurrentUser
) -> Tenant:
    tenant = Tenant(unit_id=unit.id, **payload.model_dump())
    db.add(tenant)
    db.commit()
    db.refresh(tenant)
    refresh_reminders_for_user(db, user)
    return tenant


@router.get("/tenants/{tenant_id}", response_model=TenantOut)
def get_tenant(tenant: OwnedTenant) -> Tenant:
    return tenant


@router.patch("/tenants/{tenant_id}", response_model=TenantOut)
def update_tenant(
    payload: TenantUpdate, tenant: OwnedTenant, db: DbSession, user: CurrentUser
) -> Tenant:
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(tenant, field, value)
    db.commit()
    db.refresh(tenant)
    refresh_reminders_for_user(db, user)
    return tenant


@router.post("/tenants/{tenant_id}/archive", response_model=TenantOut)
def archive_tenant(
    tenant: OwnedTenant, db: DbSession, user: CurrentUser
) -> Tenant:
    """Tandai penyewa sebagai tidak aktif (riwayat tetap tersimpan).
    Reminder sewa & kontrak penyewa ini otomatis dibersihkan."""
    tenant.is_active = False
    db.commit()
    db.refresh(tenant)
    refresh_reminders_for_user(db, user)
    return tenant


@router.delete("/tenants/{tenant_id}", response_model=Message)
def delete_tenant(
    tenant: OwnedTenant, db: DbSession, user: CurrentUser
) -> Message:
    """Hapus permanen. Untuk penyewa yang sudah selesai, lebih baik pakai
    /archive supaya riwayat pembayaran tidak ikut hilang."""
    db.delete(tenant)
    db.commit()
    refresh_reminders_for_user(db, user)
    return Message(message="Penyewa dihapus.")
