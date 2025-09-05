variable "name" { type = string }
variable "raw_bucket" { type = string }
variable "curated_bucket" { type = string }
variable "dlq_arn" { type = string }

data "aws_iam_policy_document" "assume" {
  statement { actions = ["sts:AssumeRole"] principals { type = "Service" identifiers = ["lambda.amazonaws.com", "states.amazonaws.com"] } }
}

resource "aws_iam_role" "this" { name = var.name assume_role_policy = data.aws_iam_policy_document.assume.json }

data "aws_iam_policy_document" "policy" {
  statement { actions = ["s3:*"] resources = ["arn:aws:s3:::${var.raw_bucket}", "arn:aws:s3:::${var.raw_bucket}/*", "arn:aws:s3:::${var.curated_bucket}", "arn:aws:s3:::${var.curated_bucket}/*"] }
  statement { actions = ["logs:*"] resources = ["*"] }
  statement { actions = ["states:*"] resources = ["*"] }
  statement { actions = ["lambda:InvokeFunction"] resources = ["*"] }
  statement { actions = ["sqs:SendMessage"] resources = [var.dlq_arn] }
}

resource "aws_iam_policy" "inline" { name = "${var.name}-policy" policy = data.aws_iam_policy_document.policy.json }
resource "aws_iam_role_policy_attachment" "att" { role = aws_iam_role.this.name policy_arn = aws_iam_policy.inline.arn }

output "arn" { value = aws_iam_role.this.arn }
