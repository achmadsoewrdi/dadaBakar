from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
import uuid

from app.core.deps import get_db, get_current_user, get_current_active_superuser
from app.modules.users.models import User
from app.modules.subscriptions import schemas, service

router = APIRouter(
    prefix="/subscriptions",
    tags=["subscriptions"]
)

@router.post("/{user_id}", response_model=schemas.SubscriptionOut, status_code=status.HTTP_201_CREATED)
async def create_subscription(
    user_id: uuid.UUID,
    sub_in: schemas.SubscriptionCreate,
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_active_superuser)
):
    """
    (ADMIN ONLY) Buat atau aktifkan paket langganan baru untuk seorang user.
    Otomatis mengubah is_premium di tabel user.
    """
    return await service.create_subscription(db, user_id, sub_in)

@router.get("/me", response_model=schemas.SubscriptionOut)
async def get_my_subscription(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Ambil langganan yang sedang aktif milik user.
    """
    sub = await service.get_active_subscription(db, current_user.id)
    if not sub:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No active subscription found")
    return sub

@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def cancel_my_subscription(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Batalkan langganan yang sedang aktif (set is_active = False, is_premium = False).
    """
    await service.cancel_subscription(db, current_user.id)
