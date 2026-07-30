from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timedelta
from uuid import UUID
from app.modules.projects.models import Project
from app.modules.projects.schemas import ProjectCreate, ProjectUpdate


async def create_project(db: AsyncSession, project_in: ProjectCreate, owner_id: UUID) -> Project:
    project = Project(
        owner_id=owner_id,
        name=project_in.name,
        workspace_xml=project_in.workspace_xml,
        generated_code=project_in.generated_code,
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
    
    if project_update.name is not None:
        project.name = project_update.name
    if project_update.workspace_xml is not None:
        project.workspace_xml = project_update.workspace_xml
    if project_update.generated_code is not None:
        project.generated_code = project_update.generated_code
    if project_update.device_profile_id is not None:
        project.device_profile_id = project_update.device_profile_id
    
    project.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(project)
    return project
