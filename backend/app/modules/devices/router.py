from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from typing import List

from app.db.session import get_db
from app.modules.devices.schemas import DeviceProfileCreate, DeviceProfileOut, DeviceProfileUpdate
from app.modules.devices import service
from app.core.deps import get_current_user
from app.modules.users.models import User

router = APIRouter(prefix="/devices", tags=["devices"])

@router.get("/", response_model=List[DeviceProfileOut])
async def list_devices(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get all devices for the current user.
    """
    return await service.get_user_devices(db, current_user.id)

@router.post("/", response_model=DeviceProfileOut, status_code=status.HTTP_201_CREATED)
async def create_new_device(
    device_in: DeviceProfileCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Create a new device for the current user.
    """
    return await service.create_device(db, device_in, current_user.id)

@router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_device(
    device_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Delete a device.
    """
    success = await service.delete_device(db, device_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Device not found")

@router.put("/{device_id}", response_model=DeviceProfileOut)
async def update_device(
    device_id: UUID,
    device_in: DeviceProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update a device's details (e.g. rename).
    """
    device = await service.update_device(db, device_id, device_in, current_user.id)
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    return device
