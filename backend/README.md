# Backend

FastAPI service responsible for job submission and retrieval.

![alt text](image.png)

## Responsibilities

- `POST /jobs` creates a job and publishes it to SQS.
- `GET /jobs` returns jobs.
- `GET /jobs/{job_id}` returns an individual job.
- PostgreSQL stores persistent job state.
- HTTP 202 is returned after successful asynchronous enqueue.

## Database

SQLAlchemy is used for database access and Alembic manages schema migrations.

The `jobs` table contains `id`, `input`, `status`, `result`, `created_at` and `updated_at`.

## Configuration

Database, Redis and SQS endpoints are supplied through Kubernetes configuration. Sensitive database credentials come from the Kubernetes Secret synchronized from AWS Secrets Manager.

## Container

The backend uses a multi-stage Python image with a virtual environment and non-root runtime user.
