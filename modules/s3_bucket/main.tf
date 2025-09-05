variable "bucket_name" { type = string }
variable "force_destroy" { type = bool default = false }

resource "aws_s3_bucket" "this" { bucket = var.bucket_name force_destroy = var.force_destroy }

resource "aws_s3_bucket_versioning" "v" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}

output "bucket" { value = aws_s3_bucket.this.bucket }
