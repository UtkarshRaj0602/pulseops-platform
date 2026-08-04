from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.health import router as health_router
from app.routes.jobs import router as jobs_router
from app.config import settings

app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    description="PulseOps Platform Backend API",
)

# -------------------------------------------------------------------
# CORS
# -------------------------------------------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",  # React Frontend
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------------------------------------------------
# Routes
# -------------------------------------------------------------------

app.include_router(
    health_router,
    tags=["Health"],
)

app.include_router(
    jobs_router,
    prefix="/jobs",
    tags=["Jobs"],
)

# -------------------------------------------------------------------
# Root Endpoint
# -------------------------------------------------------------------


@app.get("/")
def root():
    return {
        "application": settings.APP_NAME,
        "environment": settings.APP_ENV,
        "version": "1.0.0",
        "status": "running",
    }
