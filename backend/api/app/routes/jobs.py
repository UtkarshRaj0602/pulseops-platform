import uuid

from fastapi import APIRouter

from app.schemas import JobCreate

router = APIRouter()


jobs = []


@router.post("")
def create_job(job: JobCreate):

    job_id = str(uuid.uuid4())

    jobs.append({"id": job_id, "input": job.text, "status": "QUEUED", "result": None})

    return {"job_id": job_id, "message": "Job submitted successfully."}


@router.get("")
def get_jobs():

    return jobs


@router.get("/{job_id}")
def get_job(job_id: str):

    for job in jobs:

        if job["id"] == job_id:

            return job

    return {"message": "Job not found."}
