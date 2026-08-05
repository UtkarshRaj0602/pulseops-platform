resource "aws_sqs_queue" "dlq" {

  name = "${local.name_prefix}-jobs-dlq"

  message_retention_seconds = 1209600 #14days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-jobs-dlq"
    }
  )

}

resource "aws_sqs_queue" "jobs" {

  name = "${local.name_prefix}-jobs"

  visibility_timeout_seconds = 300 #5mins

  message_retention_seconds = 345600 #4days

  receive_wait_time_seconds = 20

  redrive_policy = jsonencode({

    deadLetterTargetArn = aws_sqs_queue.dlq.arn

    maxReceiveCount = 5

  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-jobs"
    }
  )

}
