import uuid
from datetime import datetime
from typing import Any
from sqlalchemy import String, Text, Boolean, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID, JSONB
from app.db.session import Base


class BlockDefinition(Base):
    """
    Definisi setiap blok Blockly beserta generator kode Python-nya
    untuk masing-masing platform hardware (Raspberry Pi, Orange Pi, ESP32).
    Tabel ini menggantikan spaghetti code di custom_blocks.js.
    """
    __tablename__ = "block_definitions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # Kategori blok, misal: gpio | sensor | motor | display | logic
    category: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    # Identifier unik blok, misal: set_pin | read_sensor | move_servo
    block_type: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    # Label yang muncul di toolbox Blockly
    label: Mapped[str] = mapped_column(String(255), nullable=False)
    # Definisi tampilan blok dalam format JSON Blockly
    toolbox_json: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    # Generator kode Python per platform hardware
    generator_raspi: Mapped[str | None] = mapped_column(Text, nullable=True)
    generator_orangepi: Mapped[str | None] = mapped_column(Text, nullable=True)
    generator_esp32: Mapped[str | None] = mapped_column(Text, nullable=True)
    # Blok premium hanya bisa dipakai user berlangganan
    is_premium_only: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    # Urutan tampil di toolbox
    order_index: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )
