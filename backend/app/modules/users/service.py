from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.modules.users.models import User
from app.modules.users.schemas import UserCreate
from app.core.security import hash_password, verify_password


async def get_user_by_email(db: AsyncSession, email: str) -> Optional[User]:
    """Mencari user berdasarkan alamat email di database PostgreSQL."""
    result = await db.execute(select(User).where(User.email == email))
    return result.scalar_one_or_none()


async def create_user(db: AsyncSession, user_in: UserCreate) -> User:
    """Membuat user baru di database dengan password yang sudah di-hash."""
    hashed_pwd = hash_password(user_in.password)
    db_user = User(
        email=user_in.email,
        hashed_password=hashed_pwd,
        full_name=user_in.full_name,
        role="user",
        is_premium=False,
        is_active=True,
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user


async def authenticate_user(db: AsyncSession, email: str, password: str) -> Optional[User]:
    """Memverifikasi email dan password user saat proses login."""
    user = await get_user_by_email(db, email=email)
    if not user:
        return None
    if not user.hashed_password:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user


async def get_user_by_google_sub(db: AsyncSession, google_sub: str) -> Optional[User]:
    """Mencari user berdasarkan google_sub (Google OAuth User ID)."""
    result = await db.execute(select(User).where(User.google_sub == google_sub))
    return result.scalar_one_or_none()


async def get_or_create_google_user(
    db: AsyncSession,
    google_sub: str,
    email: str,
    full_name: Optional[str] = None,
    photo_url: Optional[str] = None
) -> User:
    """Mengambil atau membuat akun user baru secara otomatis via Google Sign-In."""
    # 1. Cek apakah google_sub sudah terdaftar
    user = await get_user_by_google_sub(db, google_sub=google_sub)
    if user:
        # Update photo if it's missing but provided by Google
        if not user.photo_url and photo_url:
            user.photo_url = photo_url
            await db.commit()
            await db.refresh(user)
        return user

    # 2. Cek apakah email sudah terdaftar via email/password sebelumnya
    user = await get_user_by_email(db, email=email)
    if user:
        # Hubungkan akun email yang ada dengan google_sub
        user.google_sub = google_sub
        if not user.full_name and full_name:
            user.full_name = full_name
        if not user.photo_url and photo_url:
            user.photo_url = photo_url
        await db.commit()
        await db.refresh(user)
        return user

    # 3. Jika benar-benar baru, buat user baru tanpa password
    db_user = User(
        email=email,
        google_sub=google_sub,
        full_name=full_name,
        photo_url=photo_url,
        hashed_password=None,
        role="user",
        is_premium=False,
        is_active=True,
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

async def update_user_profile(
    db: AsyncSession, 
    user: User, 
    full_name: Optional[str] = None, 
    photo_url: Optional[str] = None
) -> User:
    """Memperbarui profil user (nama dan foto)."""
    if full_name is not None:
        user.full_name = full_name
    if photo_url is not None:
        user.photo_url = photo_url
        
    await db.commit()
    await db.refresh(user)
    return user
