from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

# Import all models to register SQLAlchemy relationships
import app.modules.users.models
import app.modules.projects.models
import app.modules.devices.models
import app.modules.content.models
import app.modules.hardware_types.models
import app.modules.subscriptions.models
import app.modules.gamification.models
import app.modules.blocks.models

from app.modules.users.router import router as users_router
from app.modules.projects.router import router as projects_router
from app.modules.hardware_types.router import router as hardware_types_router
from app.modules.blocks.router import router as blocks_router
from app.modules.gamification.router import router as gamification_router
from app.modules.devices.router import router as devices_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Set up CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API v1 routers
app.include_router(users_router, prefix=settings.API_V1_STR)
app.include_router(projects_router, prefix=settings.API_V1_STR)
app.include_router(hardware_types_router, prefix=settings.API_V1_STR)
app.include_router(blocks_router, prefix=settings.API_V1_STR)
app.include_router(gamification_router, prefix=settings.API_V1_STR)
app.include_router(devices_router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {
        "message": "Welcome to Xploria Developer API",
        "version": settings.VERSION,
        "docs": "/docs"
    }

@app.get("/health")
async def health_check():
    return {"status": "ok", "service": settings.PROJECT_NAME}
