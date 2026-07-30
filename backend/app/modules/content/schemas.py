from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional, Dict, Any


class LearningModuleCreate(BaseModel):
    title: str
    description: Optional[str] = None
    order_index: int = 0
    category: str = "iot_basic"
    xp_reward: int = 10
    thumbnail_url: Optional[str] = None
    steps_json: Dict[str, Any]
    is_premium_only: bool = False


class LearningModuleUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    order_index: Optional[int] = None
    category: Optional[str] = None
    xp_reward: Optional[int] = None
    thumbnail_url: Optional[str] = None
    steps_json: Optional[Dict[str, Any]] = None
    is_premium_only: Optional[bool] = None


class LearningModuleOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    title: str
    description: Optional[str] = None
    order_index: int
    category: str
    xp_reward: int
    thumbnail_url: Optional[str] = None
    steps_json: Dict[str, Any]
    is_premium_only: bool
    created_at: datetime


class UserProgressCreate(BaseModel):
    completed_steps: Optional[Dict[str, Any]] = None


class UserProgressOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    module_id: UUID
    completed_steps: Optional[Dict[str, Any]] = None
    completed_at: Optional[datetime] = None
    xp_earned: int
