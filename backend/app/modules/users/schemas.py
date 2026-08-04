from uuid import UUID
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, ConfigDict

# schema untuk reques pendaftaran user baru
class UserCreate(BaseModel):
    email:EmailStr
    password: str
    full_name: Optional[str] = None

# schema untuk reques Login user
class UserLogin(BaseModel):
    email: EmailStr
    password: str

# schema untuk request Login via Google OAuth
class GoogleLogin(BaseModel):
    id_token: str

# schema untuk response Profile User (Data yang di kembalikan ke frontend)
class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    email: EmailStr
    full_name: str | None = None
    photo_url: str | None = None
    role: str
    is_premium: bool
    is_active: bool
    created_at: datetime

# schema untuk response token jwt
class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserOut

# schema untuk payload
class TokenPayload(BaseModel):
    sub: Optional[str] = None
    type: Optional[str] = None
