import uuid

from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException
from fastapi import status

from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Job
from app.redis_client import add_recent_job
from app.redis_client import cache_job
from app.redis_client import get_cached_job
from app.redis_client import get_recent_job_ids
from app.schemas import JobCreate
from app.schemas import JobCreateResponse
from app.schemas import JobResponse
from app.sqs import send_job

router = APIRouter()


def serialize_job(job: Job) -> dict:
    return {
        "id": str(job.id),
        "input": job.input,
        "status": job.status,
        "result": job.result,
        "created_at": job.created_at,
        "updated_at": job.updated_at,
    }


@router.post(
    "",
    response_model=JobCreateResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
def create_job(
    payload: JobCreate,
    db: Session = Depends(get_db),
):
    job_id = str(uuid.uuid4())

    job = Job(
        id=job_id,
        input=payload.text,
        status="QUEUED",
        result=None,
    )

    # --------------------------------------------------
    # 1. Store job in PostgreSQL
    # --------------------------------------------------

    try:
        db.add(job)
        db.commit()
        db.refresh(job)

    except Exception:
        db.rollback()

        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Failed to create job in database",
        )

    # --------------------------------------------------
    # 2. Send job to SQS
    # --------------------------------------------------

    try:
        send_job(job_id)

    # except Exception:
    #     job.status = "FAILED"

    #     try:
    #         db.commit()
    #     except Exception:
    #         db.rollback()

    #     raise HTTPException(
    #         status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
    #         detail="Failed to enqueue job",
    #     )

    except Exception as exc:
        job.status = "FAILED"
        db.commit()
        print(f"SQS enqueue failed: {type(exc).__name__}: {exc}", flush=True)
        raise HTTPException(status_code=503, detail=f"Failed to enqueue job: {exc}")

    # --------------------------------------------------
    # 3. Cache initial job state
    #
    # Redis is a cache, so failure here must NOT make
    # the API request fail.
    # --------------------------------------------------

    job_data = serialize_job(job)

    try:
        cache_job(job_data)
        add_recent_job(job_id)

    except Exception:
        # Redis failure should not affect the job.
        pass

    # --------------------------------------------------
    # 4. Return 202 Accepted
    # --------------------------------------------------

    return {
        "job_id": job_id,
        "status": "QUEUED",
        "message": "Job submitted successfully.",
    }


@router.get(
    "",
    response_model=list[JobResponse],
)
def get_jobs(
    db: Session = Depends(get_db),
):
    # --------------------------------------------------
    # Try Redis for recent job IDs
    # --------------------------------------------------

    try:
        recent_ids = get_recent_job_ids()

    except Exception:
        recent_ids = []

    # --------------------------------------------------
    # Redis has recent job IDs
    # --------------------------------------------------

    if recent_ids:

        jobs = db.query(Job).filter(Job.id.in_(recent_ids)).all()

        jobs_by_id = {str(job.id): job for job in jobs}

        result = []

        for job_id in recent_ids:

            job = jobs_by_id.get(job_id)

            if job:
                result.append(serialize_job(job))

        return result

    # --------------------------------------------------
    # Redis unavailable/empty
    # → PostgreSQL fallback
    # --------------------------------------------------

    jobs = db.query(Job).order_by(Job.created_at.desc()).limit(10).all()

    return [serialize_job(job) for job in jobs]


@router.get(
    "/{job_id}",
    response_model=JobResponse,
)
def get_job(
    job_id: str,
    db: Session = Depends(get_db),
):
    # --------------------------------------------------
    # 1. Try Redis
    # --------------------------------------------------

    try:
        cached_job = get_cached_job(job_id)

    except Exception:
        cached_job = None

    if cached_job:
        return cached_job

    # --------------------------------------------------
    # 2. Redis miss
    # → PostgreSQL
    # --------------------------------------------------

    job = db.query(Job).filter(Job.id == job_id).first()

    if job is None:

        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Job not found",
        )

    job_data = serialize_job(job)

    # --------------------------------------------------
    # 3. Repopulate Redis
    #
    # Redis failure should not affect response.
    # --------------------------------------------------

    try:
        cache_job(job_data)
    except Exception:
        pass

    return job_data
