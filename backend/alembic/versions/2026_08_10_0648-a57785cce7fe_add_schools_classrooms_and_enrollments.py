"""Add schools classrooms and enrollments

Revision ID: a57785cce7fe
Revises: '60af5e678a38'
Create Date: 2026-08-10 06:48:47.991640+00:00

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa


from sqlalchemy.dialects import postgresql

revision: str = 'a57785cce7fe'
down_revision: Union[str, None] = '60af5e678a38'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ── SCHOOLS ──
    op.create_table(
        'schools',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('address', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )

    # ── CLASSROOMS ──
    op.create_table(
        'classrooms',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('school_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('teacher_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('code', sa.String(length=20), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['school_id'], ['schools.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['teacher_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('code')
    )
    # Index for classrooms code as requested
    op.create_index('ix_classrooms_code', 'classrooms', ['code'])

    # ── ENROLLMENTS ──
    op.create_table(
        'enrollments',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('classroom_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('student_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('enrolled_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['classroom_id'], ['classrooms.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['student_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('classroom_id', 'student_id', name='uq_enrollment')
    )

    # ── MODIFIKASI USERS ──
    op.add_column('users',
        sa.Column('school_id', postgresql.UUID(as_uuid=True), nullable=True)
    )
    op.add_column('users',
        sa.Column('onboarding_source', sa.String(length=50), nullable=True)
    )
    op.create_foreign_key(
        'fk_users_school',
        'users', 'schools',
        ['school_id'], ['id'],
        ondelete='SET NULL'
    )
    
    # Check Constraint untuk role di tabel users (user, siswa, guru, admin)
    op.create_check_constraint(
        'ck_users_role',
        'users',
        sa.column('role').in_(['user', 'siswa', 'guru', 'admin'])
    )


def downgrade() -> None:
    # Rollback tabel-tabel baru (users, enrollments, classrooms, schools)
    op.drop_constraint('ck_users_role', 'users', type_='check')
    op.drop_constraint('fk_users_school', 'users', type_='foreignkey')
    op.drop_column('users', 'onboarding_source')
    op.drop_column('users', 'school_id')
    op.drop_table('enrollments')
    op.drop_index('ix_classrooms_code', table_name='classrooms')
    op.drop_table('classrooms')
    op.drop_table('schools')
