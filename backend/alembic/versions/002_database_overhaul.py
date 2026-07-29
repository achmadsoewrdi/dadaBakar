"""Database Overhaul: Hardware types, subscriptions, gamification, blocks

Revision ID: 002_database_overhaul
Revises: 001_initial_schema
Create Date: 2026-07-29

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = '002_database_overhaul'
down_revision: Union[str, None] = '001_initial_schema'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ── 1. HARDWARE TYPES ────────────────────────────────────────────
    op.create_table(
        'hardware_types',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('name', sa.String(length=50), nullable=False),
        sa.Column('display_name', sa.String(length=100), nullable=False),
        sa.Column('pin_map_json', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('name')
    )
    op.create_index('ix_hardware_types_name', 'hardware_types', ['name'])

    # Seed 3 hardware types
    op.execute("""
        INSERT INTO hardware_types (name, display_name, description) VALUES
        ('raspberry_pi', 'Raspberry Pi', 'Single-board computer dari Raspberry Pi Foundation'),
        ('orange_pi', 'Orange Pi', 'Single-board computer dari Shenzhen Xunlong Software'),
        ('esp32', 'ESP32', 'Mikrokontroler Wi-Fi + Bluetooth dari Espressif Systems')
    """)

    # ── 2. SUBSCRIPTIONS ─────────────────────────────────────────────
    op.create_table(
        'subscriptions',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('tier', sa.String(length=20), server_default='free', nullable=False),
        sa.Column('started_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('is_active', sa.Boolean(), server_default=sa.text('true'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_subscriptions_user_id', 'subscriptions', ['user_id'])

    # ── 3. BADGES ────────────────────────────────────────────────────
    op.create_table(
        'badges',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('icon_url', sa.String(length=500), nullable=True),
        sa.Column('xp_threshold', sa.Integer(), nullable=True),
        sa.Column('type', sa.String(length=30), server_default='special', nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('name')
    )

    # Seed badge awal
    op.execute("""
        INSERT INTO badges (name, description, xp_threshold, type) VALUES
        ('Pemula', 'Selamat datang di Xploria!', 0, 'special'),
        ('Explorer', 'Kamu sudah mengumpulkan 100 XP', 100, 'streak'),
        ('Builder', 'Kamu sudah mengumpulkan 500 XP', 500, 'project'),
        ('Master', 'Kamu sudah mengumpulkan 1000 XP', 1000, 'project')
    """)

    # ── 4. USER BADGES ───────────────────────────────────────────────
    op.create_table(
        'user_badges',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('badge_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('earned_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['badge_id'], ['badges.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_user_badges_user_id', 'user_badges', ['user_id'])

    # ── 5. USER GAMIFICATION ─────────────────────────────────────────
    op.create_table(
        'user_gamification',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('total_xp', sa.Integer(), server_default='0', nullable=False),
        sa.Column('level', sa.Integer(), server_default='1', nullable=False),
        sa.Column('current_streak', sa.Integer(), server_default='0', nullable=False),
        sa.Column('longest_streak', sa.Integer(), server_default='0', nullable=False),
        sa.Column('last_activity_at', sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id')
    )
    op.create_index('ix_user_gamification_user_id', 'user_gamification', ['user_id'])

    # ── 6. BLOCK DEFINITIONS ─────────────────────────────────────────
    op.create_table(
        'block_definitions',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('category', sa.String(length=50), nullable=False),
        sa.Column('block_type', sa.String(length=100), nullable=False),
        sa.Column('label', sa.String(length=255), nullable=False),
        sa.Column('toolbox_json', postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column('generator_raspi', sa.Text(), nullable=True),
        sa.Column('generator_orangepi', sa.Text(), nullable=True),
        sa.Column('generator_esp32', sa.Text(), nullable=True),
        sa.Column('is_premium_only', sa.Boolean(), server_default=sa.text('false'), nullable=False),
        sa.Column('order_index', sa.Integer(), server_default='0', nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('block_type')
    )
    op.create_index('ix_block_definitions_category', 'block_definitions', ['category'])
    op.create_index('ix_block_definitions_block_type', 'block_definitions', ['block_type'])

    # ── 7. MODIFIKASI device_profiles ────────────────────────────────
    op.add_column('device_profiles',
        sa.Column('hardware_type_id', postgresql.UUID(as_uuid=True), nullable=True)
    )
    op.add_column('device_profiles',
        sa.Column('hardware_variant', sa.String(length=50), nullable=True)
    )
    op.create_foreign_key(
        'fk_device_profiles_hardware_type',
        'device_profiles', 'hardware_types',
        ['hardware_type_id'], ['id'],
        ondelete='SET NULL'
    )
    op.create_index('ix_device_profiles_hardware_type_id', 'device_profiles', ['hardware_type_id'])

    # ── 8. MODIFIKASI projects ────────────────────────────────────────
    op.add_column('projects',
        sa.Column('device_profile_id', postgresql.UUID(as_uuid=True), nullable=True)
    )
    op.create_foreign_key(
        'fk_projects_device_profile',
        'projects', 'device_profiles',
        ['device_profile_id'], ['id'],
        ondelete='SET NULL'
    )
    op.create_index('ix_projects_device_profile_id', 'projects', ['device_profile_id'])
    # Hapus kolom device_type yang lama
    op.drop_column('projects', 'device_type')

    # ── 9. MODIFIKASI learning_modules ───────────────────────────────
    op.add_column('learning_modules', sa.Column('order_index', sa.Integer(), server_default='0', nullable=False))
    op.add_column('learning_modules', sa.Column('category', sa.String(length=50), server_default='iot_basic', nullable=False))
    op.add_column('learning_modules', sa.Column('xp_reward', sa.Integer(), server_default='10', nullable=False))
    op.add_column('learning_modules', sa.Column('thumbnail_url', sa.String(length=500), nullable=True))

    # ── 10. USER PROGRESS ────────────────────────────────────────────
    op.create_table(
        'user_progress',
        sa.Column('id', postgresql.UUID(as_uuid=True), server_default=sa.text('gen_random_uuid()'), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('module_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('completed_steps', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('completed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('xp_earned', sa.Integer(), server_default='0', nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['module_id'], ['learning_modules.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_user_progress_user_id', 'user_progress', ['user_id'])
    op.create_index('ix_user_progress_module_id', 'user_progress', ['module_id'])


def downgrade() -> None:
    # Urutan downgrade harus kebalikan dari upgrade
    op.drop_table('user_progress')
    op.drop_column('learning_modules', 'thumbnail_url')
    op.drop_column('learning_modules', 'xp_reward')
    op.drop_column('learning_modules', 'category')
    op.drop_column('learning_modules', 'order_index')
    op.add_column('projects', sa.Column('device_type', sa.String(length=50), nullable=True))
    op.drop_index('ix_projects_device_profile_id', table_name='projects')
    op.drop_constraint('fk_projects_device_profile', 'projects', type_='foreignkey')
    op.drop_column('projects', 'device_profile_id')
    op.drop_index('ix_device_profiles_hardware_type_id', table_name='device_profiles')
    op.drop_constraint('fk_device_profiles_hardware_type', 'device_profiles', type_='foreignkey')
    op.drop_column('device_profiles', 'hardware_variant')
    op.drop_column('device_profiles', 'hardware_type_id')
    op.drop_index('ix_block_definitions_block_type', table_name='block_definitions')
    op.drop_index('ix_block_definitions_category', table_name='block_definitions')
    op.drop_table('block_definitions')
    op.drop_index('ix_user_gamification_user_id', table_name='user_gamification')
    op.drop_table('user_gamification')
    op.drop_index('ix_user_badges_user_id', table_name='user_badges')
    op.drop_table('user_badges')
    op.drop_table('badges')
    op.drop_index('ix_subscriptions_user_id', table_name='subscriptions')
    op.drop_table('subscriptions')
    op.drop_index('ix_hardware_types_name', table_name='hardware_types')
    op.drop_table('hardware_types')
