from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from app.db.session import get_db
from app.modules.hardware_types.schemas import HardwareTypeCreate, HardwareTypeUpdate, HardwareTypeOut
from app.modules.hardware_types import service

router = APIRouter(prefix="/hardware-types", tags=["hardware-types"])


@router.get("/", response_model=list[HardwareTypeOut])
async def list_hardware_types(db: AsyncSession = Depends(get_db)):
    return await service.get_all(db)


@router.get("/{hardware_id}", response_model=HardwareTypeOut)
async def get_hardware_type(hardware_id: UUID, db: AsyncSession = Depends(get_db)):
    hw = await service.get_by_id(db, hardware_id)
    if not hw:
        raise HTTPException(status_code=404, detail="Hardware type not found")
    return hw


@router.post("/", response_model=HardwareTypeOut, status_code=status.HTTP_201_CREATED)
async def create_hardware_type(data: HardwareTypeCreate, db: AsyncSession = Depends(get_db)):
    return await service.create(db, data)


@router.patch("/{hardware_id}", response_model=HardwareTypeOut)
async def update_hardware_type(hardware_id: UUID, data: HardwareTypeUpdate, db: AsyncSession = Depends(get_db)):
    hw = await service.update(db, hardware_id, data)
    if not hw:
        raise HTTPException(status_code=404, detail="Hardware type not found")
    return hw


@router.delete("/{hardware_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_hardware_type(hardware_id: UUID, db: AsyncSession = Depends(get_db)):
    success = await service.delete(db, hardware_id)
    if not success:
        raise HTTPException(status_code=404, detail="Hardware type not found")
