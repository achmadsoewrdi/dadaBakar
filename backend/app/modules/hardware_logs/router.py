from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from typing import List
from app.core.deps import get_db, get_current_user
from app.modules.users.models import User
from app.modules.devices.service import get_device_profile
from app.modules.hardware_logs.schemas import HardwareLogCreate, HardwareLogOut
from app.modules.hardware_logs import service

router = APIRouter(prefix="/hardware-logs", tags=["hardware-logs"])

@router.get("/device/{device_profile_id}", response_model=List[HardwareLogOut])
async def get_hardware_logs(
    device_profile_id: UUID, 
    limit: int = 100, 
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Verify device belongs to user
    device = await get_device_profile(db, device_profile_id, current_user.id)
    if not device:
        raise HTTPException(status_code=403, detail="Not authorized to view logs for this device")
    return await service.get_by_device(db, device_profile_id, limit)

@router.post("/", response_model=HardwareLogOut, status_code=status.HTTP_201_CREATED)
async def create_hardware_log(
    data: HardwareLogCreate, 
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Verify device belongs to user
    device = await get_device_profile(db, data.device_profile_id, current_user.id)
    if not device:
        raise HTTPException(status_code=403, detail="Not authorized to log for this device")
    return await service.create(db, data)
