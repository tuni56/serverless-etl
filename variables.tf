variable "project" { type = string }
variable "region"  { type = string  default = "us-east-1" }
variable "env"     { type = string  default = "dev" }
variable "schedule_expression" { type = string default = "rate(5 minutes)" }
