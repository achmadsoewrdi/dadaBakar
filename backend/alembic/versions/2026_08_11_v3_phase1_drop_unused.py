"""phase1_drop_gamification_school_tables

Revision ID: v3_phase1_drop_unused
Revises: 2026_08_10_0648-a57785cce7fe_add_schools_classrooms_and_enrollments
Create Date: 2026-08-11

Deskripsi:
    Fase 1 Xploria v3 — Penghapusan.
    Menghapus tabel-tabel yang tidak lagi digunakan:
    - Gamifikasi: user_badges, user_gamification, badges
    - School/Classroom: enrollments, classrooms, schools
    - Kolom: users.school_id, users.onboarding_source
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'v3_phase1_drop_unused'
down_revision: Union[str, None] = '60af5e678a38'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ── GAMIFIKASI ─────────────────────────────────────────────────────────────
    op.execute("DROP TABLE IF EXISTS user_badges CASCADE")
    op.execute("DROP TABLE IF EXISTS user_gamification CASCADE")
    op.execute("DROP TABLE IF EXISTS badges CASCADE")

    # ── KOLOM DI USERS ─────────────────────────────────────────────────────────
    # Drop FK constraint dulu sebelum drop tabel schools
    op.execute("ALTER TABLE users DROP CONSTRAINT IF EXISTS fk_users_school")
    op.execute("ALTER TABLE users DROP CONSTRAINT IF EXISTS users_school_id_fkey")
    op.execute("ALTER TABLE users DROP COLUMN IF EXISTS school_id")
    op.execute("ALTER TABLE users DROP COLUMN IF EXISTS onboarding_source")

    # ── SCHOOL / CLASSROOM ─────────────────────────────────────────────────────
    op.execute("DROP TABLE IF EXISTS enrollments CASCADE")
    op.execute("DROP TABLE IF EXISTS classrooms CASCADE")
    op.execute("DROP TABLE IF EXISTS schools CASCADE")


def downgrade() -> None:
    # ── RESTORE KOLOM USERS ────────────────────────────────────────────────────
    op.add_column('users',
        sa.Column('onboarding_source', sa.String(50), nullable=True)
    )
    op.add_column('users',
        sa.Column('school_id', postgresql.UUID(as_uuid=True), nullable=True)
    )

    # ── RESTORE SCHOOLS ────────────────────────────────────────────────────────
    op.create_table(
        'schools',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('address', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    )

    op.create_table(
        'classrooms',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('school_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('schools.id', ondelete='CASCADE'), nullable=False),
        sa.Column('teacher_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('code', sa.String(20), nullable=False, unique=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    )

    op.create_table(
        'enrollments',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('classroom_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('classrooms.id', ondelete='CASCADE'), nullable=False),
        sa.Column('student_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('enrolled_at', sa.DateTime(timezone=True), nullable=False),
    )

    op.create_foreign_key('users_school_id_fkey', 'users', 'schools', ['school_id'], ['id'])

    # ── RESTORE BADGES ─────────────────────────────────────────────────────────
    op.create_table(
        'badges',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('name', sa.String(100), nullable=False, unique=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('icon_url', sa.String(500), nullable=True),
        sa.Column('xp_threshold', sa.Integer(), nullable=True),
        sa.Column('type', sa.String(30), nullable=False, default='special'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    )

    op.create_table(
        'user_gamification',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False, unique=True),
        sa.Column('total_xp', sa.Integer(), nullable=False, default=0),
        sa.Column('level', sa.Integer(), nullable=False, default=1),
        sa.Column('current_streak', sa.Integer(), nullable=False, default=0),
        sa.Column('longest_streak', sa.Integer(), nullable=False, default=0),
        sa.Column('last_activity_at', sa.DateTime(timezone=True), nullable=True),
    )

    op.create_table(
        'user_badges',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('badge_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('badges.id', ondelete='CASCADE'), nullable=False),
        sa.Column('earned_at', sa.DateTime(timezone=True), nullable=False),
    )
