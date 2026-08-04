import json
import time

from sqlalchemy.orm import Session

from database import SessionLocal
from models import Job

from sqs import sqs
from config import settings

from processor import process_job
from redis_client import redis_client

print("Worker started...")


while True:

    response = sqs.receive_message(
        QueueUrl=settings.SQS_QUEUE_URL, MaxNumberOfMessages=1, WaitTimeSeconds=20
    )

    messages = response.get("Messages", [])

    if not messages:
        continue

    message = messages[0]

    receipt_handle = message["ReceiptHandle"]

    body = json.loads(message["Body"])

    payload = json.loads(body["Message"])

    job_id = payload["job_id"]

    db: Session = SessionLocal()

    try:

        job = db.query(Job).filter(Job.id == job_id).first()

        if job is None:
            continue

        job.status = "PROCESSING"

        db.commit()

        result = process_job(job.input)

        job.result = result
        job.status = "COMPLETED"

        db.commit()

        redis_client.setex(
            f"job:{job.id}",
            600,
            json.dumps({"status": job.status, "result": job.result}),
        )

        sqs.delete_message(
            QueueUrl=settings.SQS_QUEUE_URL, ReceiptHandle=receipt_handle
        )

        print(f"Processed Job {job.id}")

    except Exception as e:

        print(e)

        if job:

            job.status = "FAILED"

            db.commit()

    finally:

        db.close()

    time.sleep(1)
