from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, timedelta
from uuid import UUID
from fastapi import HTTPException, status
from app.modules.projects.models import Project
from app.modules.projects.schemas import ProjectCreate, ProjectUpdate
from app.core.config import settings


async def _count_active_projects(db: AsyncSession, owner_id: UUID) -> int:
    """Menghitung jumlah proyek aktif (non-soft-deleted) milik owner."""
    result = await db.execute(
        select(func.count()).where(
            Project.owner_id == owner_id,
            Project.deleted_at.is_(None),
        )
    )
    return result.scalar_one()


async def create_project(
    db: AsyncSession,
    project_in: ProjectCreate,
    owner_id: UUID,
    is_premium: bool = False,
) -> Project:
    """Membuat proyek baru.

    Untuk user free/demo, jumlah proyek aktif dibatasi oleh ``settings.FREE_PROJECT_QUOTA``
    sesuai plan.md §1.2 FR #7: enforcement di backend, bukan hanya di client.
    """
    if not is_premium:
        count = await _count_active_projects(db, owner_id)
        if count >= settings.FREE_PROJECT_QUOTA:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"Batas proyek untuk akun free adalah {settings.FREE_PROJECT_QUOTA}. "
                    "Upgrade ke Xploria Pro untuk proyek tanpa batas."
                ),
            )

    project = Project(
        owner_id=owner_id,
        name=project_in.name,
        workspace_xml=project_in.workspace_xml,
        generated_code=project_in.generated_code,
        blynk_config_json=project_in.blynk_config_json,
        device_profile_id=project_in.device_profile_id,
    )
    db.add(project)
    await db.commit()
    await db.refresh(project)
    return project


async def get_active_projects(db: AsyncSession, owner_id: UUID) -> list[Project]:
    result = await db.execute(
        select(Project).where(Project.owner_id == owner_id, Project.deleted_at.is_(None))
    )
    return list(result.scalars().all())


async def soft_delete_project(db: AsyncSession, project_id: UUID, owner_id: UUID) -> bool:
    result = await db.execute(
        select(Project).where(Project.id == project_id, Project.owner_id == owner_id, Project.deleted_at.is_(None))
    )
    project = result.scalar_one_or_none()
    if not project:
        return False
    project.deleted_at = datetime.utcnow()
    await db.commit()
    return True


async def restore_project(db: AsyncSession, project_id: UUID, owner_id: UUID) -> bool:
    result = await db.execute(
        select(Project).where(Project.id == project_id, Project.owner_id == owner_id)
    )
    project = result.scalar_one_or_none()
    if not project or project.deleted_at is None:
        return False
    if project.deleted_at < datetime.utcnow() - timedelta(days=30):
        return False  # Exceeded 30-day restore period
    project.deleted_at = None
    await db.commit()
    return True

async def update_project(db: AsyncSession, project_id: UUID, owner_id: UUID, project_update: ProjectUpdate) -> Project | None:
    result = await db.execute(
        select(Project).where(Project.id == project_id, Project.owner_id == owner_id, Project.deleted_at.is_(None))
    )
    project = result.scalar_one_or_none()
    if not project:
        return None
    
    update_data = project_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(project, key, value)
    
    project.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(project)
    return project
