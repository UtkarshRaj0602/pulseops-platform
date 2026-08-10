import boto3

from config import settings

sqs = boto3.client("sqs", region_name=settings.AWS_REGION)
