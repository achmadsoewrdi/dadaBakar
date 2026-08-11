import random
import string
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import HTTPException, status
from app.modules.school.models import Classroom, Enrollment
from app.modules.school.schemas import ClassroomCreate

def _generate_classroom_code() -> str:
    """Generate a 6-character uppercase alphanumeric code (Kahoot style)."""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

async def create_classroom(db: AsyncSession, classroom_in: ClassroomCreate, teacher_id: UUID) -> Classroom:
    """Creates a new classroom."""
    
    # Generate unique code
    max_retries = 5
    for _ in range(max_retries):
        code = _generate_classroom_code()
        # Check if code already exists
        result = await db.execute(select(Classroom).where(Classroom.code == code))
        if not result.scalar_one_or_none():
            break
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate unique classroom code."
        )

    classroom = Classroom(
        school_id=classroom_in.school_id,
        teacher_id=teacher_id,
        name=classroom_in.name,
        code=code
    )
    
    db.add(classroom)
    await db.commit()
    await db.refresh(classroom)
    return classroom

async def join_classroom(db: AsyncSession, code: str, student_id: UUID) -> Enrollment:
    """Joins a classroom using a code."""
    
    # Find classroom by code
    result = await db.execute(select(Classroom).where(Classroom.code == code.upper()))
    classroom = result.scalar_one_or_none()
    
    if not classroom:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Classroom not found. Please check the code."
        )
        
    # Check if already enrolled
    enrollment_result = await db.execute(
        select(Enrollment).where(
            Enrollment.classroom_id == classroom.id,
            Enrollment.student_id == student_id
        )
    )
    existing_enrollment = enrollment_result.scalar_one_or_none()
    
    if existing_enrollment:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You are already enrolled in this classroom."
        )
        
    # Create enrollment
    enrollment = Enrollment(
        classroom_id=classroom.id,
        student_id=student_id
    )
    
    db.add(enrollment)
    await db.commit()
    await db.refresh(enrollment)
    
    return enrollment

async def get_classrooms_by_teacher(db: AsyncSession, teacher_id: UUID) -> list[Classroom]:
    result = await db.execute(select(Classroom).where(Classroom.teacher_id == teacher_id))
    return list(result.scalars().all())

async def get_enrolled_classrooms(db: AsyncSession, student_id: UUID) -> list[Classroom]:
    result = await db.execute(
        select(Classroom).join(Enrollment).where(Enrollment.student_id == student_id)
    )
    return list(result.scalars().all())
