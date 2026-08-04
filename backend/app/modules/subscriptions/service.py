import uuid
from datetime import datetime, timedelta
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from app.modules.subscriptions.models import Subscription
from app.modules.subscriptions.schemas import SubscriptionCreate
from app.modules.users.models import User

async def create_subscription(db: AsyncSession, user_id: uuid.UUID, sub_in: SubscriptionCreate) -> Subscription:
    # Set expiration depending on tier
    days = 30 if sub_in.tier == "monthly" else (365 if sub_in.tier == "yearly" else 0)
    
    expires_at = None
    if days > 0:
        expires_at = datetime.utcnow() + timedelta(days=days)
        
    subscription = Subscription(
        user_id=user_id,
        tier=sub_in.tier,
        started_at=datetime.utcnow(),
        expires_at=expires_at,
        is_active=True
    )
    
    db.add(subscription)
    
    # Update user's is_premium flag
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if user:
        user.is_premium = True
        
    await db.commit()
    await db.refresh(subscription)
    return subscription

async def get_active_subscription(db: AsyncSession, user_id: uuid.UUID) -> Subscription | None:
    result = await db.execute(
        select(Subscription)
        .where(Subscription.user_id == user_id, Subscription.is_active == True)
        .order_by(Subscription.created_at.desc())
    )
    return result.scalars().first()

async def cancel_subscription(db: AsyncSession, user_id: uuid.UUID) -> bool:
    sub = await get_active_subscription(db, user_id)
    if not sub:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No active subscription found")
        
    sub.is_active = False
    
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if user:
        user.is_premium = False
        
    await db.commit()
    return True
