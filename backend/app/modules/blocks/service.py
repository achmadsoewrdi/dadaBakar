from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timedelta
from uuid import UUID
from app.modules.blocks.models import BlockDefinition
from app.modules.blocks.schemas import BlockDefinitionCreate, BlockDefinitionUpdate


async def get_all(db: AsyncSession, category: str | None = None) -> list[BlockDefinition]:
    query = select(BlockDefinition).order_by(BlockDefinition.category, BlockDefinition.order_index)
    if category:
        query = query.where(BlockDefinition.category == category)
    result = await db.execute(query)
    return list(result.scalars().all())


async def get_by_id(db: AsyncSession, block_id: UUID) -> BlockDefinition | None:
    result = await db.execute(select(BlockDefinition).where(BlockDefinition.id == block_id))
    return result.scalar_one_or_none()


async def get_by_block_type(db: AsyncSession, block_type: str) -> BlockDefinition | None:
    result = await db.execute(select(BlockDefinition).where(BlockDefinition.block_type == block_type))
    return result.scalar_one_or_none()


async def create(db: AsyncSession, data: BlockDefinitionCreate) -> BlockDefinition:
    block = BlockDefinition(**data.model_dump())
    db.add(block)
    await db.commit()
    await db.refresh(block)
    return block


async def update(db: AsyncSession, block_id: UUID, data: BlockDefinitionUpdate) -> BlockDefinition | None:
    block = await get_by_id(db, block_id)
    if not block:
        return None
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(block, field, value)
    await db.commit()
    await db.refresh(block)
    return block


async def delete(db: AsyncSession, block_id: UUID) -> bool:
    block = await get_by_id(db, block_id)
    if not block:
        return False
    await db.delete(block)
    await db.commit()
    return True
