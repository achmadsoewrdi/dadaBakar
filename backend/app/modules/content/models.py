import uuid
from datetime import datetime
from typing import Any
from sqlalchemy import String, Text, Boolean, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.db.session import Base


class LearningModule(Base):
    __tablename__ = "learning_modules"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    # Urutan tampil di halaman modul
    order_index: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    # Kategori modul, misal: iot_basic | hardware | advanced | quiz
    category: Mapped[str] = mapped_column(String(50), nullable=False, default="iot_basic")
    # Berapa XP yang diperoleh user setelah menyelesaikan modul ini
    xp_reward: Mapped[int] = mapped_column(Integer, default=10, nullable=False)
    thumbnail_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    # Langkah-langkah dalam modul disimpan sebagai JSONB
    steps_json: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    is_premium_only: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)

    # Relationships
    user_progress = relationship("UserProgress", back_populates="module")


class UserProgress(Base):
    """Progress belajar seorang user pada satu modul tertentu."""
    __tablename__ = "user_progress"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    module_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("learning_modules.id", ondelete="CASCADE"), nullable=False, index=True
    )
    # Menyimpan step mana saja yang sudah diselesaikan, misal: {"completed": [1, 2, 3]}
    completed_steps: Mapped[dict[str, Any] | None] = mapped_column(JSONB, nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    xp_earned: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # Relationships
    user = relationship("User", back_populates="user_progress")
    module = relationship("LearningModule", back_populates="user_progress")
