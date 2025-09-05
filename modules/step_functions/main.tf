variable "name" { type = string }
variable "role_arn" { type = string }
variable "definition" { type = string }
variable "lambda_arns_map" { type = map(string) }

locals {
  def = replace(replace(replace(replace(var.definition,
    "\"${Validate}\"", jsonencode(var.lambda_arns_map["Validate"])),
    "\"${Enrich}\"",   jsonencode(var.lambda_arns_map["Enrich"])),
    "\"${Transform}\"",jsonencode(var.lambda_arns_map["Transform"])),
    "\"${Upload}\"",   jsonencode(var.lambda_arns_map["Upload"]))
}

resource "aws_sfn_state_machine" "sm" {
  name     = var.name
  role_arn = var.role_arn
  definition = local.def
}

output "arn" { value = aws_sfn_state_machine.sm.arn }
