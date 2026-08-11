from uuid import UUID
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

# --- School Schemas ---

class SchoolBase(BaseModel):
    name: str
    address: Optional[str] = None

class SchoolCreate(SchoolBase):
    pass

class SchoolOut(SchoolBase):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    created_at: datetime

class VerifyInviteTokenRequest(BaseModel):
    invite_token: str
    role: str # "siswa" or "guru"

# --- Classroom Schemas ---

class ClassroomBase(BaseModel):
    name: str

class ClassroomCreate(ClassroomBase):
    school_id: UUID

class ClassroomOut(ClassroomBase):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    school_id: UUID
    teacher_id: UUID
    code: str
    created_at: datetime

class JoinClassroomRequest(BaseModel):
    code: str

class EnrollmentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    classroom_id: UUID
    student_id: UUID
    enrolled_at: datetime
