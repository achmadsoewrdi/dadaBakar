from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from app.db.session import get_db
from app.modules.devices.schemas import DeviceProfileCreate, DeviceProfileOut, DeviceProfileUpdate
from app.modules.devices import service
from app.core.deps import get_current_user
from app.modules.users.models import User

router = APIRouter(prefix="/devices", tags=["devices"])

@router.post("/", response_model=DeviceProfileOut, status_code=status.HTTP_201_CREATED)
async def create_new_device_profile(
    device_in: DeviceProfileCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    return await service.create_device_profile(db, device_in, current_user.id)

@router.get("/", response_model=list[DeviceProfileOut])
async def list_device_profiles(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    return await service.get_device_profiles(db, current_user.id)

@router.get("/{device_id}", response_model=DeviceProfileOut)
async def get_device_profile_by_id(
    device_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    device = await service.get_device_profile(db, device_id, current_user.id)
    if not device:
        raise HTTPException(status_code=404, detail="Device profile not found")
    return device

@router.put("/{device_id}", response_model=DeviceProfileOut)
async def update_device_profile(
    device_id: UUID,
    device_update: DeviceProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    device = await service.update_device_profile(db, device_id, current_user.id, device_update)
    if not device:
        raise HTTPException(status_code=404, detail="Device profile not found")
    return device

@router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_device_profile(
    device_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    success = await service.delete_device_profile(db, device_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Device profile not found")
