from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from app.db.session import get_db
from app.modules.projects.schemas import ProjectCreate, ProjectOut, ProjectUpdate
from app.modules.projects import service
from app.core.deps import get_current_user
from app.modules.users.models import User

router = APIRouter(prefix="/projects", tags=["projects"])

@router.post("/", response_model=ProjectOut, status_code=status.HTTP_201_CREATED)
async def create_new_project(
    project_in: ProjectCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    return await service.create_project(db, project_in, current_user.id)

@router.get("/", response_model=list[ProjectOut])
async def list_projects(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    return await service.get_active_projects(db, current_user.id)

@router.put("/{project_id}", response_model=ProjectOut)
async def update_project(
    project_id: UUID,
    project_update: ProjectUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    project = await service.update_project(db, project_id, current_user.id, project_update)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project

@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
async def soft_delete(
    project_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    success = await service.soft_delete_project(db, project_id, current_user.id)
    if not success:
        raise HTTPException(status_code=404, detail="Project not found or already deleted")

@router.post("/{project_id}/restore", status_code=status.HTTP_200_OK)
async def restore(
    project_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    success = await service.restore_project(db, project_id, current_user.id)
    if not success:
        raise HTTPException(status_code=400, detail="Cannot restore project (expired or not found)")
    return {"message": "Project restored successfully"}
