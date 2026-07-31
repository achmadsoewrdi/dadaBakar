from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from uuid import UUID
from app.modules.devices.models import DeviceProfile
from app.modules.devices.schemas import DeviceProfileCreate, DeviceProfileUpdate

async def create_device_profile(db: AsyncSession, device_in: DeviceProfileCreate, owner_id: UUID) -> DeviceProfile:
    device = DeviceProfile(
        owner_id=owner_id,
        label=device_in.label,
        protocol=device_in.protocol,
        hardware_type_id=device_in.hardware_type_id,
        hardware_variant=device_in.hardware_variant,
        host=device_in.host,
        port=device_in.port,
        use_tls=device_in.use_tls,
        mac_address=device_in.mac_address,
    )
    db.add(device)
    await db.commit()
    await db.refresh(device)
    # eager load hardware_type to avoid lazy loading issues on serialization if needed
    result = await db.execute(select(DeviceProfile).options(selectinload(DeviceProfile.hardware_type)).where(DeviceProfile.id == device.id))
    return result.scalar_one()

async def get_device_profiles(db: AsyncSession, owner_id: UUID) -> list[DeviceProfile]:
    result = await db.execute(
        select(DeviceProfile)
        .options(selectinload(DeviceProfile.hardware_type))
        .where(DeviceProfile.owner_id == owner_id)
    )
    return list(result.scalars().all())

async def get_device_profile(db: AsyncSession, device_id: UUID, owner_id: UUID) -> DeviceProfile | None:
    result = await db.execute(
        select(DeviceProfile)
        .options(selectinload(DeviceProfile.hardware_type))
        .where(DeviceProfile.id == device_id, DeviceProfile.owner_id == owner_id)
    )
    return result.scalar_one_or_none()

async def update_device_profile(db: AsyncSession, device_id: UUID, owner_id: UUID, device_update: DeviceProfileUpdate) -> DeviceProfile | None:
    device = await get_device_profile(db, device_id, owner_id)
    if not device:
        return None
    
    update_data = device_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(device, key, value)
        
    await db.commit()
    await db.refresh(device)
    return device

async def delete_device_profile(db: AsyncSession, device_id: UUID, owner_id: UUID) -> bool:
    device = await get_device_profile(db, device_id, owner_id)
    if not device:
        return False
    await db.delete(device)
    await db.commit()
    return True
