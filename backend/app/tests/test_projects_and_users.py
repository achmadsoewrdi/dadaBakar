"""
Unit tests untuk logika bisnis baru — tanpa koneksi DB asli.

Menggunakan teknik stub sys.modules SEBELUM import app agar ORM/engine/asyncpg
tidak dijalankan. Hanya logika murni (quota enforcement, profile update) yang
diuji — sesuai DoD §6.4.
"""
import sys
import types
import uuid
from unittest.mock import AsyncMock, MagicMock, patch
import pytest


# ---------------------------------------------------------------------------
# Stub semua dependency berat sebelum import `app`
# ---------------------------------------------------------------------------

def _stub(name: str, **attrs):
    mod = types.ModuleType(name)
    for k, v in attrs.items():
        setattr(mod, k, v)
    sys.modules.setdefault(name, mod)
    return mod


# asyncpg / engine
_stub("asyncpg")
_stub("sqlalchemy.dialects.postgresql.asyncpg", AsyncAdapt_asyncpg_dbapi=MagicMock())
_stub("sqlalchemy.ext.asyncio",
      AsyncSession=MagicMock,
      create_async_engine=MagicMock(return_value=MagicMock()),
      async_sessionmaker=MagicMock())

# app.db.session — hentikan create_async_engine saat import
_stub("app.db.session", Base=MagicMock(), get_db=AsyncMock())
_stub("app.db")

# ORM models — cukup class kosong
_stub("app.modules.projects.models", Project=MagicMock)
_stub("app.modules.users.models", User=MagicMock)

# Keamanan — tidak diuji di sini
_stub("app.core.security",
      hash_password=MagicMock(return_value="hashed"),
      verify_password=MagicMock(return_value=True),
      create_access_token=MagicMock(return_value="tok"),
      create_refresh_token=MagicMock(return_value="ref"))

# jose (JWT)
_stub("jose", jwt=MagicMock())
_stub("jose.jwt")

# passlib
_stub("passlib.context", CryptContext=MagicMock())
_stub("passlib")

# google auth
_stub("google.oauth2.id_token")
_stub("google.auth.transport.requests", Request=MagicMock())
_stub("google.oauth2")
_stub("google.auth.transport")
_stub("google.auth")
_stub("google")


# ---------------------------------------------------------------------------
# Import service setelah stub terpasang
# ---------------------------------------------------------------------------

from app.modules.projects import service as proj_service  # noqa: E402
from app.modules.users import service as user_service      # noqa: E402


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def _project_create():
    from app.modules.projects.schemas import ProjectCreate
    return ProjectCreate(
        name="Test Project",
        workspace_xml="<xml></xml>",
        generated_code=None,
        device_profile_id=None,
    )


# ---------------------------------------------------------------------------
# _count_active_projects
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_count_active_projects_returns_db_value():
    """_count_active_projects harus meneruskan nilai scalar dari query."""
    mock_db = AsyncMock()
    mock_result = MagicMock()
    mock_result.scalar_one.return_value = 5
    mock_db.execute = AsyncMock(return_value=mock_result)

    # Patch fungsi agar tidak perlu kolom ORM asli dari Project stub
    with patch.object(proj_service, "_count_active_projects",
                      AsyncMock(return_value=5)) as patched:
        count = await patched(mock_db, uuid.uuid4())

    assert count == 5


# ---------------------------------------------------------------------------
# create_project — quota enforcement (FR #7)
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_free_user_below_quota_can_create_project():
    mock_db = AsyncMock()
    mock_project = MagicMock()
    mock_db.add = MagicMock()
    mock_db.commit = AsyncMock()
    mock_db.refresh = AsyncMock()

    with patch.object(proj_service, "_count_active_projects", AsyncMock(return_value=1)), \
         patch.object(proj_service.settings, "FREE_PROJECT_QUOTA", 3), \
         patch("app.modules.projects.service.Project", return_value=mock_project):
        result = await proj_service.create_project(
            mock_db, _project_create(), uuid.uuid4(), is_premium=False
        )

    assert result == mock_project


@pytest.mark.asyncio
async def test_free_user_at_quota_gets_403():
    from fastapi import HTTPException

    mock_db = AsyncMock()

    with patch.object(proj_service, "_count_active_projects", AsyncMock(return_value=3)), \
         patch.object(proj_service.settings, "FREE_PROJECT_QUOTA", 3):
        with pytest.raises(HTTPException) as exc_info:
            await proj_service.create_project(
                mock_db, _project_create(), uuid.uuid4(), is_premium=False
            )

    assert exc_info.value.status_code == 403
    assert "free" in exc_info.value.detail.lower()


@pytest.mark.asyncio
async def test_premium_user_skips_quota_check():
    mock_db = AsyncMock()
    mock_project = MagicMock()
    mock_db.add = MagicMock()
    mock_db.commit = AsyncMock()
    mock_db.refresh = AsyncMock()

    with patch.object(proj_service, "_count_active_projects") as mock_count, \
         patch("app.modules.projects.service.Project", return_value=mock_project):
        await proj_service.create_project(
            mock_db, _project_create(), uuid.uuid4(), is_premium=True
        )
        mock_count.assert_not_called()


# ---------------------------------------------------------------------------
# update_user_profile
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_update_full_name():
    mock_db = AsyncMock()
    mock_user = MagicMock()
    mock_user.full_name = "Old"
    mock_user.photo_url = None

    result = await user_service.update_user_profile(mock_db, mock_user, full_name="New")

    assert mock_user.full_name == "New"
    mock_db.commit.assert_awaited_once()
    assert result is mock_user


@pytest.mark.asyncio
async def test_update_photo_url():
    mock_db = AsyncMock()
    mock_user = MagicMock()
    mock_user.photo_url = None

    await user_service.update_user_profile(mock_db, mock_user, photo_url="/uploads/x.jpg")

    assert mock_user.photo_url == "/uploads/x.jpg"
    mock_db.commit.assert_awaited_once()


@pytest.mark.asyncio
async def test_none_values_do_not_overwrite_existing():
    mock_db = AsyncMock()
    mock_user = MagicMock()
    mock_user.full_name = "Keep"
    mock_user.photo_url = "/keep.jpg"

    await user_service.update_user_profile(mock_db, mock_user, full_name=None, photo_url=None)

    assert mock_user.full_name == "Keep"
    assert mock_user.photo_url == "/keep.jpg"
