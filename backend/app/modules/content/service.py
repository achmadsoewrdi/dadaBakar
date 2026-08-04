from typing import Optional, Dict, Any, Union
from uuid import UUID
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.modules.content.models import LearningModule, UserProgress
from app.modules.content.schemas import LearningModuleCreate, LearningModuleUpdate
from app.modules.gamification.service import add_xp


async def get_all_modules(
    db: AsyncSession,
    category: Optional[str] = None,
    is_premium: Optional[bool] = None
) -> list[LearningModule]:
    """Mengambil daftar semua modul pembelajaran dengan filter opsional kategori dan akses premium."""
    query = select(LearningModule).order_by(LearningModule.order_index)
    if category:
        query = query.where(LearningModule.category == category)
    if is_premium is not None:
        query = query.where(LearningModule.is_premium_only == is_premium)
    
    result = await db.execute(query)
    return list(result.scalars().all())


async def get_module_by_id(
    db: AsyncSession,
    module_id: UUID
) -> Optional[LearningModule]:
    """Mengambil detail modul pembelajaran berdasarkan module_id."""
    result = await db.execute(
        select(LearningModule).where(LearningModule.id == module_id)
    )
    return result.scalar_one_or_none()


async def get_user_progress(
    db: AsyncSession,
    user_id: UUID,
    module_id: Optional[UUID] = None
) -> Union[list[UserProgress], Optional[UserProgress]]:
    """
    Mengambil progress belajar user.
    Jika module_id diberikan, mengembalikan progress user pada modul tersebut.
    Jika module_id None, mengembalikan daftar seluruh progress user.
    """
    if module_id:
        result = await db.execute(
            select(UserProgress).where(
                UserProgress.user_id == user_id,
                UserProgress.module_id == module_id
            )
        )
        return result.scalar_one_or_none()

    result = await db.execute(
        select(UserProgress).where(UserProgress.user_id == user_id)
    )
    return list(result.scalars().all())


async def update_progress(
    db: AsyncSession,
    user_id: UUID,
    module_id: UUID,
    completed_steps: Optional[Dict[str, Any]] = None
) -> Optional[UserProgress]:
    """
    Meng-update progress modul user dan memberikan XP reward jika pertama kali selesai.
    """
    module = await get_module_by_id(db, module_id)
    if not module:
        return None

    result = await db.execute(
        select(UserProgress).where(
            UserProgress.user_id == user_id,
            UserProgress.module_id == module_id
        )
    )
    progress = result.scalar_one_or_none()

    if not progress:
        progress = UserProgress(
            user_id=user_id,
            module_id=module_id,
            completed_steps=completed_steps,
        )
        db.add(progress)
    else:
        progress.completed_steps = completed_steps

    # Berikan XP reward jika user belum pernah mendapatkan XP untuk modul ini
    if progress.xp_earned == 0 and module.xp_reward > 0:
        progress.xp_earned = module.xp_reward
        progress.completed_at = datetime.utcnow()
        await add_xp(db, user_id=user_id, xp=module.xp_reward)

    await db.commit()
    await db.refresh(progress)
    return progress


async def create_module(
    db: AsyncSession,
    data: LearningModuleCreate
) -> LearningModule:
    """Membuat modul pembelajaran baru (helper/admin function)."""
    module = LearningModule(**data.model_dump())
    db.add(module)
    await db.commit()
    await db.refresh(module)
    return module


async def update_module(
    db: AsyncSession,
    module_id: UUID,
    data: LearningModuleUpdate
) -> Optional[LearningModule]:
    """Meng-update modul pembelajaran yang ada."""
    module = await get_module_by_id(db, module_id)
    if not module:
        return None
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(module, field, value)
    await db.commit()
    await db.refresh(module)
    return module


async def delete_module(
    db: AsyncSession,
    module_id: UUID
) -> bool:
    """Menghapus modul pembelajaran berdasarkan ID."""
    module = await get_module_by_id(db, module_id)
    if not module:
        return False
    await db.delete(module)
    await db.commit()
    return True
