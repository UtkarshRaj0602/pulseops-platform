# from fastapi import APIRouter

# router = APIRouter(prefix="/health")


# @router.get("/live")
# def liveness():
#     return {"status": "alive"}


# @router.get("/ready")
# def readiness():
#     """
#     Later we will check:
#     - PostgreSQL
#     - Redis

#     For now simply return ready.
#     """
#     return {"status": "ready"}


from fastapi import APIRouter
from fastapi import HTTPException
from sqlalchemy import text

from app.database import engine
from app.redis_client import check_redis

router = APIRouter(prefix="/health")


@router.get("/live")
def liveness():

    return {"status": "alive"}


@router.get("/ready")
def readiness():

    # --------------------------------------------------
    # PostgreSQL
    # --------------------------------------------------

    try:

        with engine.connect() as connection:

            connection.execute(text("SELECT 1"))

    except Exception:

        raise HTTPException(
            status_code=503,
            detail={
                "status": "not_ready",
                "database": "unavailable",
            },
        )

    # --------------------------------------------------
    # Redis
    # --------------------------------------------------

    if not check_redis():

        raise HTTPException(
            status_code=503,
            detail={
                "status": "not_ready",
                "redis": "unavailable",
            },
        )

    return {
        "status": "ready",
        "database": "ok",
        "redis": "ok",
    }
