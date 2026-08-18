from datetime import datetime, timedelta, timezone
from typing import Any, Union
from jose import jwt
from passlib.context import CryptContext
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    # mengecek password mentah jadi hash string
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    # memverifikasi password
    return pwd_context.verify(plain_password, hashed_password)

def _create_token(subject: Union[str, Any], token_type: str, expires_delta: timedelta = None) -> str:
    """Private helper to create JWT tokens."""
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        if token_type == "access":
            expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        else:
            expire = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "type": token_type
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def create_access_token(subject: Union[str, Any], expires_delta: timedelta = None) -> str:
    # membuat jwt access token (token sementara) autentikasi request API
    return _create_token(subject, "access", expires_delta)

def create_refresh_token(subject: Union[str, Any], expires_delta: timedelta = None) -> str:
    # membuat jwt refresh token (durasi panjang)
    return _create_token(subject, "refresh", expires_delta)

        