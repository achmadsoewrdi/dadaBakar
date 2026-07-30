from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from google.oauth2 import id_token as google_id_token  # type: ignore
from google.auth.transport import requests as google_requests  # type: ignore

from app.core.config import settings
from app.core.deps import get_db, get_current_user
from app.core.security import create_access_token, create_refresh_token
from app.modules.users.models import User
from app.modules.users.schemas import UserCreate, UserLogin, UserOut, Token, GoogleLogin
from app.modules.users.service import (
    get_user_by_email,
    create_user,
    authenticate_user,
    get_or_create_google_user,
)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register_user(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk Pendaftaran Akun Baru.
    - Memvalidasi format email dan password.
    - Menolak request jika email sudah terdaftar.
    - Mengembalikan data user baru tanpa password (UserOut).
    """
    user = await get_user_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email ini sudah terdaftar di sistem."
        )
    
    new_user = await create_user(db, user_in=user_in)
    
    access_token = create_access_token(subject=new_user.id)
    refresh_token = create_refresh_token(subject=new_user.id)
    
    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=new_user
    )


@router.post("/login", response_model=Token)
async def login_user(
    user_in: UserLogin,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk Login Pengguna.
    - Memverifikasi email dan password dengan hash di database.
    - Mengembalikan JWT Access Token dan Refresh Token jika sukses.
    """
    user = await authenticate_user(db, email=user_in.email, password=user_in.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email atau password yang Anda masukkan salah."
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Akun Anda sedang dinonaktifkan."
        )

    # Buat Access Token dan Refresh Token berbasis ID user
    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)

    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=user
    )


@router.get("/me", response_model=UserOut)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user)
):
    """
    Endpoint Terlindungi (Protected Endpoint).
    - Membutuhkan Header 'Authorization: Bearer <access_token>'.
    - Mengembalikan profil lengkap user yang sedang aktif.
    """
    return current_user


@router.post("/google", response_model=Token)
async def google_login(
    payload: GoogleLogin,
    db: AsyncSession = Depends(get_db)
):
    """
    Endpoint untuk Autentikasi Google Sign-In.
    - Menerima `id_token` hasil verifikasi Google dari Flutter app.
    - Memverifikasi keabsahan `id_token` ke Google Auth Server.
    - Mengambil atau otomatis membuatkan akun user baru di database.
    - Mengembalikan JWT Access Token dan Refresh Token.
    """
    try:
        # Verifikasi ID Token langsung ke server Google
        id_info = google_id_token.verify_oauth2_token(
            payload.id_token,
            google_requests.Request(),
            audience=settings.GOOGLE_CLIENT_ID if settings.GOOGLE_CLIENT_ID else None
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Token Google tidak valid: {str(e)}"
        )

    google_sub = id_info.get("sub")
    email = id_info.get("email")
    full_name = id_info.get("name")

    if not google_sub or not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Gagal mendapatkan data identitas dari Google."
        )

    # Otomatis ambil atau buatkan user di database PostgreSQL
    user = await get_or_create_google_user(
        db,
        google_sub=google_sub,
        email=email,
        full_name=full_name
    )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Akun Anda sedang dinonaktifkan."
        )

    # Buat JWT Access Token dan Refresh Token
    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)

    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=user
    )
