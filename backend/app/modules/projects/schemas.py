from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional


class ProjectCreate(BaseModel):
    name: str
    workspace_xml: str
    generated_code: Optional[str] = None
    device_profile_id: Optional[UUID] = None


class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    workspace_xml: Optional[str] = None
    generated_code: Optional[str] = None
    device_profile_id: Optional[UUID] = None


class ProjectOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    owner_id: UUID
    name: str
    workspace_xml: str
    generated_code: Optional[str] = None
    device_profile_id: Optional[UUID] = None
    created_at: datetime
    updated_at: datetime
    deleted_at: Optional[datetime] = None
