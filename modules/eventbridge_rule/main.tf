variable "name" { type = string }
variable "description" { type = string }
variable "schedule_expression" { type = string }
variable "target_arn" { type = string }

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = var.name
  description         = var.description
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  arn       = var.target_arn
  role_arn  = null
}
