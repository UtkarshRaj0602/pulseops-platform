import json

import redis

from app.config import settings

redis_client = redis.Redis(
    host=settings.REDIS_HOST,
    port=settings.REDIS_PORT,
    decode_responses=True,
)


def cache_job(job: dict) -> None:

    redis_client.setex(
        f"job:{job['id']}",
        settings.REDIS_TTL,
        json.dumps(job),
    )


def get_cached_job(job_id: str):

    data = redis_client.get(f"job:{job_id}")

    if not data:
        return None

    return json.loads(data)


def add_recent_job(job_id: str) -> None:

    redis_client.lpush(
        "recent_jobs",
        job_id,
    )

    redis_client.ltrim(
        "recent_jobs",
        0,
        9,
    )


def get_recent_job_ids():

    return redis_client.lrange(
        "recent_jobs",
        0,
        9,
    )


def check_redis() -> bool:

    try:
        return redis_client.ping()

    except Exception:
        return False
