output "queue_url" {
  description = "Main Queue URL"
  value       = aws_sqs_queue.jobs.id
}

output "queue_arn" {
  description = "Main Queue ARN"
  value       = aws_sqs_queue.jobs.arn
}

output "queue_name" {
  description = "Main Queue Name"
  value       = aws_sqs_queue.jobs.name
}

output "dlq_url" {
  description = "Dead Letter Queue URL"
  value       = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  description = "Dead Letter Queue ARN"
  value       = aws_sqs_queue.dlq.arn
}
