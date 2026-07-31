from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional

class HardwareLogCreate(BaseModel):
    device_profile_id: UUID
    log_level: Optional[str] = "INFO"
    log_message: str

class HardwareLogOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: UUID
    device_profile_id: UUID
    log_level: str
    log_message: str
    created_at: datetime
