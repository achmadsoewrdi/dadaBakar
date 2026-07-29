from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from typing import Optional
from app.db.session import get_db
from app.modules.blocks.schemas import (
    BlockDefinitionCreate, BlockDefinitionUpdate, BlockDefinitionOut, BlockDefinitionSummary
)
from app.modules.blocks import service

router = APIRouter(prefix="/blocks", tags=["blocks"])


@router.get("/", response_model=list[BlockDefinitionSummary])
async def list_blocks(category: Optional[str] = None, db: AsyncSession = Depends(get_db)):
    """List semua blok, bisa difilter per kategori."""
    return await service.get_all(db, category)


@router.get("/{block_id}", response_model=BlockDefinitionOut)
async def get_block(block_id: UUID, db: AsyncSession = Depends(get_db)):
    """Ambil satu blok beserta generator code-nya."""
    block = await service.get_by_id(db, block_id)
    if not block:
        raise HTTPException(status_code=404, detail="Block not found")
    return block


@router.get("/by-type/{block_type}", response_model=BlockDefinitionOut)
async def get_block_by_type(block_type: str, db: AsyncSession = Depends(get_db)):
    """Ambil blok berdasarkan block_type (misal: set_pin)."""
    block = await service.get_by_block_type(db, block_type)
    if not block:
        raise HTTPException(status_code=404, detail="Block not found")
    return block


@router.post("/", response_model=BlockDefinitionOut, status_code=status.HTTP_201_CREATED)
async def create_block(data: BlockDefinitionCreate, db: AsyncSession = Depends(get_db)):
    return await service.create(db, data)


@router.patch("/{block_id}", response_model=BlockDefinitionOut)
async def update_block(block_id: UUID, data: BlockDefinitionUpdate, db: AsyncSession = Depends(get_db)):
    block = await service.update(db, block_id, data)
    if not block:
        raise HTTPException(status_code=404, detail="Block not found")
    return block


@router.delete("/{block_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_block(block_id: UUID, db: AsyncSession = Depends(get_db)):
    success = await service.delete(db, block_id)
    if not success:
        raise HTTPException(status_code=404, detail="Block not found")
