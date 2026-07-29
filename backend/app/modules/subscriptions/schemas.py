from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional


class SubscriptionCreate(BaseModel):
    # Tier yang dipilih: monthly | yearly
    tier: str


class SubscriptionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    tier: str
    started_at: datetime
    expires_at: Optional[datetime] = None
    is_active: bool
    created_at: datetime
