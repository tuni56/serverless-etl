variable "name_prefix" { type = string }
resource "aws_sqs_queue" "dlq" {
  name                       = "${var.name_prefix}-dlq"
  message_retention_seconds  = 1209600
}
output "arn" { value = aws_sqs_queue.dlq.arn }
output "url" { value = aws_sqs_queue.dlq.id }
