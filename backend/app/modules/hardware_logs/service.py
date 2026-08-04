from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import desc
from uuid import UUID
from app.modules.devices.models import HardwareLog
from app.modules.hardware_logs.schemas import HardwareLogCreate
from typing import Sequence

async def get_by_device(db: AsyncSession, device_profile_id: UUID, limit: int = 100) -> Sequence[HardwareLog]:
    result = await db.execute(
        select(HardwareLog)
        .where(HardwareLog.device_profile_id == device_profile_id)
        .order_by(desc(HardwareLog.created_at))
        .limit(limit)
    )
    return result.scalars().all()

async def create(db: AsyncSession, data: HardwareLogCreate) -> HardwareLog:
    new_log = HardwareLog(**data.model_dump())
    db.add(new_log)
    await db.commit()
    await db.refresh(new_log)
    return new_log
