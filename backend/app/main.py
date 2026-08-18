from fastapi import FastAPI, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.core.deps import get_db
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from app.core.config import settings

# Import all models to register SQLAlchemy relationships
import app.modules.users.models
import app.modules.projects.models
import app.modules.devices.models
import app.modules.content.models
import app.modules.hardware_types.models
import app.modules.subscriptions.models
import app.modules.blocks.models

from app.modules.users.router import router as users_router
from app.modules.projects.router import router as projects_router
from app.modules.hardware_types.router import router as hardware_types_router
from app.modules.blocks.router import router as blocks_router
from app.modules.content.router import router as content_router
from app.modules.hardware_logs.router import router as hardware_logs_router
from app.modules.devices.router import router as devices_router
from app.modules.subscriptions.router import router as subscriptions_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Set up CORS middleware
# Using * for allow_origins and True for allow_credentials is not allowed by CORS spec
# Use specific origins via env variables in a real deployment
origins_env = os.getenv("ALLOWED_ORIGINS", "*")
allowed_origins = origins_env.split(",") if origins_env != "*" else ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=(origins_env != "*"),  # Only allow credentials if origins are explicit
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for uploads
os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Include API v1 routers
app.include_router(users_router, prefix=settings.API_V1_STR)
app.include_router(projects_router, prefix=settings.API_V1_STR)
app.include_router(hardware_types_router, prefix=settings.API_V1_STR)
app.include_router(blocks_router, prefix=settings.API_V1_STR)
app.include_router(content_router, prefix=settings.API_V1_STR)
app.include_router(hardware_logs_router, prefix=settings.API_V1_STR)
app.include_router(devices_router, prefix=settings.API_V1_STR)
app.include_router(subscriptions_router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {
        "message": "Welcome to Xploria Developer API",
        "version": settings.VERSION,
        "docs": "/docs"
    }

@app.get("/health")
async def health_check(db: AsyncSession = Depends(get_db)):
    try:
        await db.execute(text("SELECT 1"))
        db_status = "connected"
    except Exception as e:
        db_status = f"error: {str(e)}"
    
    return {
        "status": "ok", 
        "service": settings.PROJECT_NAME,
        "database": db_status
    }
