from uuid import UUID
from typing import AsyncGenerator
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.config import settings
from app.db.session import AsyncSessionLocal
from app.modules.users.models import User
from app.modules.users.schemas import TokenPayload

# Menyiapkan skema OAuth2 Bearer (Otomatis memunculkan tombol 'Authorize' di Swagger UI /docs)
reusable_oauth2 = OAuth2PasswordBearer(
    tokenUrl=f"{settings.API_V1_STR}/auth/login"
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Dependency FastAPI untuk menyediakan sesi database PostgreSQL per-request."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()


async def get_current_user(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(reusable_oauth2)
) -> User:
    """
    Dependency untuk memvalidasi Header 'Authorization: Bearer <token>'.
    Mendekode token JWT dan mengambil data User aktif dari database.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token tidak valid atau telah kadaluarsa",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # 1. Dekode token JWT menggunakan SECRET_KEY & ALGORITHM
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")

        # 2. Pastikan payload berisi user_id dan berjenis 'access' token
        if user_id is None or token_type != "access":
            raise credentials_exception
            
        token_data = TokenPayload(sub=user_id, type=token_type)
    except (JWTError, ValueError):
        raise credentials_exception

    # 3. Cari user di database PostgreSQL berdasarkan UUID
    try:
        result = await db.execute(select(User).where(User.id == UUID(token_data.sub)))
        user = result.scalar_one_or_none()
    except Exception:
        raise credentials_exception

    # 4. Validasi keberadaan dan status keaktifan user
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Pengguna tidak ditemukan"
        )
        
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Akun pengguna tidak aktif"
        )

    return user
