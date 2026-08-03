from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from uuid import UUID
from typing import List, Optional

from app.modules.devices.models import DeviceProfile
from app.modules.devices.schemas import DeviceProfileCreate, DeviceProfileUpdate

async def get_user_devices(db: AsyncSession, user_id: UUID) -> List[DeviceProfile]:
    result = await db.execute(
        select(DeviceProfile).where(DeviceProfile.owner_id == user_id).order_by(DeviceProfile.created_at.desc())
    )
    return result.scalars().all()

async def create_device(db: AsyncSession, device_in: DeviceProfileCreate, user_id: UUID) -> DeviceProfile:
    db_obj = DeviceProfile(
        **device_in.model_dump(exclude_unset=True),
        owner_id=user_id
    )
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj

async def delete_device(db: AsyncSession, device_id: UUID, user_id: UUID) -> bool:
    result = await db.execute(
        select(DeviceProfile).where(
            DeviceProfile.id == device_id,
            DeviceProfile.owner_id == user_id
        )
    )
    db_obj = result.scalar_one_or_none()
    if db_obj:
        await db.delete(db_obj)
        await db.commit()
        return True
    return False

async def update_device(db: AsyncSession, device_id: UUID, device_in: DeviceProfileUpdate, user_id: UUID) -> Optional[DeviceProfile]:
    result = await db.execute(
        select(DeviceProfile).where(
            DeviceProfile.id == device_id,
            DeviceProfile.owner_id == user_id
        )
    )
    db_obj = result.scalar_one_or_none()
    if not db_obj:
        return None
        
    update_data = device_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_obj, field, value)
        
    await db.commit()
    await db.refresh(db_obj)
    return db_obj
