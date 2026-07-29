from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timedelta
from uuid import UUID
from app.modules.gamification.models import UserGamification, Badge, UserBadge


async def get_or_create_gamification(db: AsyncSession, user_id: UUID) -> UserGamification:
    """Ambil data gamifikasi user, buat jika belum ada."""
    result = await db.execute(select(UserGamification).where(UserGamification.user_id == user_id))
    gami = result.scalar_one_or_none()
    if not gami:
        gami = UserGamification(user_id=user_id)
        db.add(gami)
        await db.commit()
        await db.refresh(gami)
    return gami


def _calculate_level(total_xp: int) -> int:
    """Hitung level berdasarkan total XP. Setiap 100 XP = 1 level."""
    return max(1, total_xp // 100 + 1)


async def add_xp(db: AsyncSession, user_id: UUID, xp: int) -> UserGamification:
    """Tambah XP ke user dan update streak harian."""
    gami = await get_or_create_gamification(db, user_id)
    now = datetime.utcnow()

    # Update streak
    if gami.last_activity_at:
        delta = now.date() - gami.last_activity_at.date()
        if delta.days == 1:
            gami.current_streak += 1
        elif delta.days > 1:
            gami.current_streak = 1
        # delta.days == 0 berarti masih hari yang sama, streak tidak berubah
    else:
        gami.current_streak = 1

    gami.longest_streak = max(gami.longest_streak, gami.current_streak)
    gami.last_activity_at = now
    gami.total_xp += xp
    gami.level = _calculate_level(gami.total_xp)

    await db.commit()
    await db.refresh(gami)

    # Auto-award badge berdasarkan XP threshold
    await _check_and_award_badges(db, user_id, gami.total_xp)

    return gami


async def _check_and_award_badges(db: AsyncSession, user_id: UUID, total_xp: int) -> None:
    """Cek badge berdasarkan XP threshold dan award jika belum punya."""
    badges_result = await db.execute(
        select(Badge).where(Badge.xp_threshold <= total_xp, Badge.xp_threshold.isnot(None))
    )
    eligible_badges = list(badges_result.scalars().all())

    for badge in eligible_badges:
        existing = await db.execute(
            select(UserBadge).where(UserBadge.user_id == user_id, UserBadge.badge_id == badge.id)
        )
        if not existing.scalar_one_or_none():
            user_badge = UserBadge(user_id=user_id, badge_id=badge.id)
            db.add(user_badge)

    await db.commit()


async def get_user_badges(db: AsyncSession, user_id: UUID) -> list[UserBadge]:
    result = await db.execute(
        select(UserBadge).where(UserBadge.user_id == user_id)
    )
    return list(result.scalars().all())


async def get_all_badges(db: AsyncSession) -> list[Badge]:
    result = await db.execute(select(Badge).order_by(Badge.xp_threshold))
    return list(result.scalars().all())
