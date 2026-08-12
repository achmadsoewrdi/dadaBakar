from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional


class ProjectCreate(BaseModel):
    name: str
    workspace_xml: str
    generated_code: Optional[dict] = None
    blynk_config_json: Optional[list] = None
    device_profile_id: Optional[UUID] = None
    target_hardware_type: Optional[str] = None
    execution_target: Optional[str] = "hardware"
    subject_context: Optional[str] = "coding"
    module_category: Optional[str] = None

class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    workspace_xml: Optional[str] = None
    generated_code: Optional[dict] = None
    blynk_config_json: Optional[list] = None
    device_profile_id: Optional[UUID] = None
    target_hardware_type: Optional[str] = None
    execution_target: Optional[str] = None
    subject_context: Optional[str] = None
    module_category: Optional[str] = None


class ProjectOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    owner_id: UUID
    name: str
    workspace_xml: str
    generated_code: Optional[dict] = None
    blynk_config_json: Optional[list] = None
    device_profile_id: Optional[UUID] = None
    target_hardware_type: Optional[str] = None
    execution_target: Optional[str] = "hardware"
    subject_context: Optional[str] = "coding"
    module_category: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    deleted_at: Optional[datetime] = None
