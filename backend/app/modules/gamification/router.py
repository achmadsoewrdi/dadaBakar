from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from app.db.session import get_db
from app.modules.gamification.schemas import UserGamificationOut, UserBadgeOut, BadgeOut, AddXpRequest
from app.modules.gamification import service

router = APIRouter(prefix="/gamification", tags=["gamification"])


@router.get("/me/{user_id}", response_model=UserGamificationOut)
async def get_my_gamification(user_id: UUID, db: AsyncSession = Depends(get_db)):
    """Ambil data XP, level, dan streak milik user."""
    return await service.get_or_create_gamification(db, user_id)


@router.post("/me/{user_id}/add-xp", response_model=UserGamificationOut)
async def add_xp(user_id: UUID, data: AddXpRequest, db: AsyncSession = Depends(get_db)):
    """Tambahkan XP ke user (dipanggil setelah selesai modul, buat project, dll)."""
    return await service.add_xp(db, user_id, data.xp)


@router.get("/me/{user_id}/badges", response_model=list[UserBadgeOut])
async def get_my_badges(user_id: UUID, db: AsyncSession = Depends(get_db)):
    """Ambil semua badge yang sudah diraih user."""
    return await service.get_user_badges(db, user_id)


@router.get("/badges", response_model=list[BadgeOut])
async def list_all_badges(db: AsyncSession = Depends(get_db)):
    """List semua badge yang tersedia (untuk halaman achievements)."""
    return await service.get_all_badges(db)
