from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from typing import Optional

from app.core.deps import get_db
from app.modules.content.schemas import (
    LearningModuleOut,
    LearningModuleCreate,
    LearningModuleUpdate,
    UserProgressOut,
    UserProgressCreate,
)
from app.modules.content import service

router = APIRouter(prefix="/content", tags=["Content"])


@router.get("/modules/", response_model=list[LearningModuleOut])
async def list_modules(
    category: Optional[str] = None,
    premium: Optional[bool] = Query(None, alias="premium"),
    is_premium: Optional[bool] = None,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk mengambil daftar semua modul pembelajaran.
    Filter opsional berdasarkan `category` dan `premium` / `is_premium`.
    """
    filter_premium = premium if premium is not None else is_premium
    return await service.get_all_modules(db, category=category, is_premium=filter_premium)


@router.post("/modules/", response_model=LearningModuleOut, status_code=status.HTTP_201_CREATED)
async def create_module(
    module_in: LearningModuleCreate,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk membuat modul pembelajaran baru.
    """
    return await service.create_module(db, data=module_in)


@router.get("/modules/{module_id}", response_model=LearningModuleOut)
async def get_module_detail(
    module_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk mengambil detail modul pembelajaran tertentu.
    """
    module = await service.get_module_by_id(db, module_id=module_id)
    if not module:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Modul pembelajaran tidak ditemukan."
        )
    return module


@router.patch("/modules/{module_id}", response_model=LearningModuleOut)
async def update_module(
    module_id: UUID,
    module_in: LearningModuleUpdate,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk memperbarui (update) data modul pembelajaran.
    """
    module = await service.update_module(db, module_id=module_id, data=module_in)
    if not module:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Modul pembelajaran tidak ditemukan."
        )
    return module


@router.delete("/modules/{module_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_module(
    module_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk menghapus modul pembelajaran.
    """
    success = await service.delete_module(db, module_id=module_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Modul pembelajaran tidak ditemukan."
        )


@router.get("/progress/{user_id}", response_model=list[UserProgressOut])
async def list_user_progress(
    user_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk mengambil semua progress belajar milik user tertentu.
    """
    return await service.get_user_progress(db, user_id=user_id)


@router.post("/progress/{user_id}/{module_id}", response_model=UserProgressOut)
async def update_user_progress(
    user_id: UUID,
    module_id: UUID,
    progress_in: UserProgressCreate,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk meng-update progress belajar user pada modul tertentu dan memberikan XP reward.
    """
    progress = await service.update_progress(
        db,
        user_id=user_id,
        module_id=module_id,
        completed_steps=progress_in.completed_steps
    )
    if not progress:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Modul pembelajaran tidak ditemukan."
        )
    return progress
