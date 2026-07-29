from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.modules.hardware_types.models import HardwareType
from app.modules.hardware_types.schemas import HardwareTypeCreate, HardwareTypeUpdate
from uuid import UUID


async def get_all(db: AsyncSession) -> list[HardwareType]:
    result = await db.execute(select(HardwareType).order_by(HardwareType.name))
    return list(result.scalars().all())


async def get_by_id(db: AsyncSession, hardware_id: UUID) -> HardwareType | None:
    result = await db.execute(select(HardwareType).where(HardwareType.id == hardware_id))
    return result.scalar_one_or_none()


async def create(db: AsyncSession, data: HardwareTypeCreate) -> HardwareType:
    hw = HardwareType(**data.model_dump())
    db.add(hw)
    await db.commit()
    await db.refresh(hw)
    return hw


async def update(db: AsyncSession, hardware_id: UUID, data: HardwareTypeUpdate) -> HardwareType | None:
    hw = await get_by_id(db, hardware_id)
    if not hw:
        return None
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(hw, field, value)
    await db.commit()
    await db.refresh(hw)
    return hw


async def delete(db: AsyncSession, hardware_id: UUID) -> bool:
    hw = await get_by_id(db, hardware_id)
    if not hw:
        return False
    await db.delete(hw)
    await db.commit()
    return True
