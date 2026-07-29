from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional


# ── Badge Schemas ──────────────────────────────────────────────────
class BadgeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    description: Optional[str] = None
    icon_url: Optional[str] = None
    xp_threshold: Optional[int] = None
    type: str
    created_at: datetime


class UserBadgeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    badge_id: UUID
    earned_at: datetime
    badge: BadgeOut


# ── Gamification Schemas ───────────────────────────────────────────
class UserGamificationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    total_xp: int
    level: int
    current_streak: int
    longest_streak: int
    last_activity_at: Optional[datetime] = None


class AddXpRequest(BaseModel):
    xp: int
    source: str  # misal: "complete_module" | "first_project" | "daily_login"
