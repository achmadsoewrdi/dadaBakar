import uuid
from datetime import datetime
from sqlalchemy import String, Text, DateTime, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.db.session import Base


class Project(Base):
    __tablename__ = "projects"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # FK ke device_profiles: project terhubung ke device yang dipakai
    device_profile_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("device_profiles.id", ondelete="SET NULL"), nullable=True, index=True
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    workspace_xml: Mapped[str] = mapped_column(Text, nullable=False)
    generated_code: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    blynk_config_json: Mapped[list | None] = mapped_column(JSONB, nullable=True)
    
    # STEM Fields
    target_hardware_type: Mapped[str | None] = mapped_column(String(50), nullable=True)
    execution_target: Mapped[str] = mapped_column(String(50), server_default="hardware", nullable=False)
    subject_context: Mapped[str] = mapped_column(String(50), server_default="coding", nullable=False)
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    # Relationships
    owner = relationship("User", back_populates="projects")
    device_profile = relationship("DeviceProfile", back_populates="projects")


__table_args__ = (
    Index("idx_projects_owner", Project.owner_id, postgresql_where=(Project.deleted_at.is_(None))),
)
