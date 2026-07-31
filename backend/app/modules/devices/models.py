import uuid
from datetime import datetime
from sqlalchemy import String, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.db.session import Base


class DeviceProfile(Base):
    __tablename__ = "device_profiles"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # FK ke hardware_types: menentukan jenis board (raspberry_pi, orange_pi, esp32)
    hardware_type_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("hardware_types.id", ondelete="SET NULL"), nullable=True, index=True
    )
    label: Mapped[str] = mapped_column(String(100), nullable=False)
    # Varian spesifik board, misal: "zero_3w", "4B", "S3", "pico"
    hardware_variant: Mapped[str | None] = mapped_column(String(50), nullable=True)
    protocol: Mapped[str] = mapped_column(String(20), nullable=False)  # websocket | bluetooth
    host: Mapped[str | None] = mapped_column(String(255), nullable=True)
    port: Mapped[int | None] = mapped_column(Integer, nullable=True)
    use_tls: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    mac_address: Mapped[str | None] = mapped_column(String(50), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    # Relationships
    owner = relationship("User", back_populates="device_profiles")
    hardware_type = relationship("HardwareType", back_populates="device_profiles")
    projects = relationship("Project", back_populates="device_profile")
    hardware_logs = relationship("HardwareLog", back_populates="device_profile", cascade="all, delete-orphan")


class HardwareLog(Base):
    __tablename__ = "hardware_logs"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_profile_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("device_profiles.id", ondelete="CASCADE"), nullable=False, index=True
    )
    log_level: Mapped[str] = mapped_column(String(20), default="INFO")
    log_message: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    # Relationships
    device_profile = relationship("DeviceProfile", back_populates="hardware_logs")
