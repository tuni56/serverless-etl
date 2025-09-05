variable "name"     { type = string }
variable "handler"  { type = string }
variable "runtime"  { type = string }
variable "role_arn" { type = string }
variable "src_dir"  { type = string }
variable "env_vars" { type = map(string) default = {} }
variable "dlq_arn"  { type = string }

resource "aws_cloudwatch_log_group" "lg" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 14
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.src_dir
  output_path = "${path.module}/../../.build/${var.name}.zip"
}

resource "aws_lambda_function" "fn" {
  function_name = var.name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn
  filename      = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  environment { variables = var.env_vars }
  dead_letter_config { target_arn = var.dlq_arn }
  timeout       = 60
  memory_size   = 512
}

output "arn" { value = aws_lambda_function.fn.arn }
