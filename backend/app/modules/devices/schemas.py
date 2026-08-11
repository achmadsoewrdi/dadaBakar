from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional
from app.modules.hardware_types.schemas import HardwareTypeOut


class DeviceProfileCreate(BaseModel):
    label: str
    protocol: str  # websocket | bluetooth | udp
    hardware_type_id: Optional[UUID] = None
    hardware_variant: Optional[str] = None
    host: Optional[str] = None
    port: Optional[int] = None
    use_tls: bool = False
    device_category: Optional[str] = None
    udp_port: Optional[int] = None
    mac_address: Optional[str] = None


class DeviceProfileUpdate(BaseModel):
    label: Optional[str] = None
    protocol: Optional[str] = None
    hardware_type_id: Optional[UUID] = None
    hardware_variant: Optional[str] = None
    host: Optional[str] = None
    port: Optional[int] = None
    use_tls: Optional[bool] = None
    device_category: Optional[str] = None
    udp_port: Optional[int] = None
    mac_address: Optional[str] = None


class DeviceProfileOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    owner_id: UUID
    label: str
    protocol: str
    hardware_type_id: Optional[UUID] = None
    hardware_variant: Optional[str] = None
    hardware_type: Optional[HardwareTypeOut] = None
    host: Optional[str] = None
    port: Optional[int] = None
    use_tls: bool
    device_category: Optional[str] = None
    udp_port: Optional[int] = None
    mac_address: Optional[str] = None
    created_at: datetime
