from fastapi import APIRouter

router = APIRouter(prefix="/health")


@router.get("/live")
def liveness():
    return {"status": "alive"}


@router.get("/ready")
def readiness():
    """
    Later we will check:
    - PostgreSQL
    - Redis

    For now simply return ready.
    """
    return {"status": "ready"}
