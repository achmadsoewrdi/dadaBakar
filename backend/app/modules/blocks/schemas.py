from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional, Any


class BlockDefinitionCreate(BaseModel):
    category: str
    block_type: str
    label: str
    toolbox_json: dict[str, Any]
    generator_raspi: Optional[str] = None
    generator_orangepi: Optional[str] = None
    generator_esp32: Optional[str] = None
    is_premium_only: bool = False
    order_index: int = 0


class BlockDefinitionUpdate(BaseModel):
    label: Optional[str] = None
    toolbox_json: Optional[dict[str, Any]] = None
    generator_raspi: Optional[str] = None
    generator_orangepi: Optional[str] = None
    generator_esp32: Optional[str] = None
    is_premium_only: Optional[bool] = None
    order_index: Optional[int] = None


class BlockDefinitionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    category: str
    block_type: str
    label: str
    toolbox_json: dict[str, Any]
    generator_raspi: Optional[str] = None
    generator_orangepi: Optional[str] = None
    generator_esp32: Optional[str] = None
    is_premium_only: bool
    order_index: int
    created_at: datetime
    updated_at: datetime


class BlockDefinitionSummary(BaseModel):
    """Schema ringkas untuk listing (tanpa generator code)."""
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    category: str
    block_type: str
    label: str
    is_premium_only: bool
    order_index: int
