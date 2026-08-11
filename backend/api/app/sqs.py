import json

import boto3

from app.config import settings

sqs = boto3.client(
    "sqs",
    region_name=settings.AWS_REGION,
)


def send_job(job_id: str) -> None:

    message = {
        "job_id": job_id,
    }

    sqs.send_message(
        QueueUrl=settings.SQS_QUEUE_URL,
        MessageBody=json.dumps(message),
    )
