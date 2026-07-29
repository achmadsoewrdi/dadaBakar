from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional, Any


class HardwareTypeCreate(BaseModel):
    name: str
    display_name: str
    pin_map_json: Optional[dict[str, Any]] = None
    description: Optional[str] = None


class HardwareTypeUpdate(BaseModel):
    display_name: Optional[str] = None
    pin_map_json: Optional[dict[str, Any]] = None
    description: Optional[str] = None


class HardwareTypeOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    display_name: str
    pin_map_json: Optional[dict[str, Any]] = None
    description: Optional[str] = None
    created_at: datetime
