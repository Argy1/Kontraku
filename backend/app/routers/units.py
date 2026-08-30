"""Endpoint unit (kamar). Rute bersarang di bawah kontrakan untuk list/create,
lalu pakai id unit langsung untuk detail/ubah/hapus."""

from __future__ import annotations

from fastapi import APIRouter, status
from sqlalchemy import select

from app.dependencies import DbSession, OwnedKontrakan, OwnedUnit
from app.models import Unit
from app.schemas.unit import UnitCreate, UnitOut, UnitUpdate

router = APIRouter(tags=["units"])


@router.get("/kontrakan/{kontrakan_id}/units", response_model=list[UnitOut])
def list_units(kontrakan: OwnedKontrakan, db: DbSession) -> list[Unit]:
    return db.scalars(
        select(Unit)
        .where(Unit.kontrakan_id == kontrakan.id)
        .order_by(Unit.name)
    ).all()


@router.post(
    "/kontrakan/{kontrakan_id}/units",
    response_model=UnitOut,
    status_code=status.HTTP_201_CREATED,
)
def create_unit(
    payload: UnitCreate, kontrakan: OwnedKontrakan, db: DbSession
) -> Unit:
    unit = Unit(kontrakan_id=kontrakan.id, **payload.model_dump())
    db.add(unit)
    db.commit()
    db.refresh(unit)
    return unit


@router.get("/units/{unit_id}", response_model=UnitOut)
def get_unit(unit: OwnedUnit) -> Unit:
    return unit


@router.patch("/units/{unit_id}", response_model=UnitOut)
def update_unit(payload: UnitUpdate, unit: OwnedUnit, db: DbSession) -> Unit:
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(unit, field, value)
    db.commit()
    db.refresh(unit)
    return unit


@router.delete("/units/{unit_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_unit(unit: OwnedUnit, db: DbSession):
    db.delete(unit)
    db.commit()
