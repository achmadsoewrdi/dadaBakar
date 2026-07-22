from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from app.db.session import get_db
from app.modules.projects.schemas import ProjectCreate, ProjectOut
from app.modules.projects import service

router = APIRouter(prefix="/projects", tags=["projects"])

@router.post("/", response_model=ProjectOut, status_code=status.HTTP_201_CREATED)
async def create_new_project(
    project_in: ProjectCreate,
    owner_id: UUID,  # Temp direct owner_id until Auth JWT middleware is attached
    db: AsyncSession = Depends(get_db)
):
    return await service.create_project(db, project_in, owner_id)

@router.get("/", response_model=list[ProjectOut])
async def list_projects(
    owner_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    return await service.get_active_projects(db, owner_id)

@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
async def soft_delete(
    project_id: UUID,
    owner_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    success = await service.soft_delete_project(db, project_id, owner_id)
    if not success:
        raise HTTPException(status_code=404, detail="Project not found or already deleted")

@router.post("/{project_id}/restore", status_code=status.HTTP_200_OK)
async def restore(
    project_id: UUID,
    owner_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    success = await service.restore_project(db, project_id, owner_id)
    if not success:
        raise HTTPException(status_code=400, detail="Cannot restore project (expired or not found)")
    return {"message": "Project restored successfully"}
