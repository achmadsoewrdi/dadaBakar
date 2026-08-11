from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from app.db.session import get_db
from app.core.deps import get_current_user
from app.modules.users.models import User
from app.modules.users.schemas import UserOut

from app.modules.school.schemas import (
    VerifyInviteTokenRequest,
    ClassroomCreate,
    ClassroomOut,
    JoinClassroomRequest,
    EnrollmentOut
)
from app.modules.school import school_service, classroom_service

router = APIRouter(tags=["School & Classrooms"])

# --- School Routes ---

from app.core.security import create_access_token, create_refresh_token
from app.modules.users.schemas import Token

@router.post("/schools/verify-invite-token", response_model=Token)
async def verify_invite_token(
    request: VerifyInviteTokenRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Verifies an invite token and assigns the 'siswa' or 'guru' role to the user,
    linking them to the appropriate school.
    Returns a new set of JWT tokens with updated role and school data.
    """
    if current_user.role in ["siswa", "guru"] and current_user.school_id is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User already has an assigned role and school."
        )
        
    user = await school_service.resolve_role_and_school(
        db, 
        user_id=current_user.id, 
        role=request.role, 
        invite_token=request.invite_token
    )

    is_onboarding_complete = bool(user.school_id and user.onboarding_source)
    access_token = create_access_token(
        subject=user.id, 
        role=user.role,
        school_id=user.school_id,
        onboarding_complete=is_onboarding_complete
    )
    refresh_token = create_refresh_token(
        subject=user.id,
        role=user.role,
        school_id=user.school_id,
        onboarding_complete=is_onboarding_complete
    )

    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=user
    )


# --- Classroom Routes ---

@router.post("/classrooms", response_model=ClassroomOut, status_code=status.HTTP_201_CREATED)
async def create_classroom_route(
    classroom_in: ClassroomCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Creates a new classroom. Only 'guru' or 'admin' can create classrooms.
    Generates a random 6-character uppercase alphanumeric code.
    """
    if current_user.role not in ["guru", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only teachers (guru) can create classrooms."
        )
        
    classroom = await classroom_service.create_classroom(db, classroom_in, current_user.id)
    return classroom


@router.post("/classrooms/join", response_model=EnrollmentOut, status_code=status.HTTP_201_CREATED)
async def join_classroom_route(
    request: JoinClassroomRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Allows a 'siswa' to join a classroom using the 6-character code.
    """
    if current_user.role != "siswa":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students (siswa) can join classrooms."
        )
        
    enrollment = await classroom_service.join_classroom(db, request.code, current_user.id)
    return enrollment


@router.get("/classrooms", response_model=List[ClassroomOut])
async def list_classrooms(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Lists classrooms for the current user.
    If 'guru', lists classrooms they teach.
    If 'siswa', lists classrooms they are enrolled in.
    """
    if current_user.role == "guru":
        return await classroom_service.get_classrooms_by_teacher(db, current_user.id)
    elif current_user.role == "siswa":
        return await classroom_service.get_enrolled_classrooms(db, current_user.id)
    else:
        # Admin or plain 'user' might see all or nothing; handle as appropriate for your app
        return []
