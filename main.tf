module "raw" {
  source       = "./modules/s3_bucket"
  bucket_name  = "${var.project}-${var.env}-raw"
  force_destroy = true
}

module "curated" {
  source       = "./modules/s3_bucket"
  bucket_name  = "${var.project}-${var.env}-curated"
  force_destroy = true
}

module "dlq" {
  source      = "./modules/sqs_dlq"
  name_prefix = "${var.project}-${var.env}"
}

module "etl_role" {
  source      = "./modules/iam_role"
  name        = "${var.project}-${var.env}-etl-role"
  raw_bucket  = module.raw.bucket
  curated_bucket = module.curated.bucket
  dlq_arn     = module.dlq.arn
}

module "validate_fn" {
  source           = "./modules/lambda_fn"
  name             = "${var.project}-${var.env}-validate"
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  role_arn         = module.etl_role.arn
  src_dir          = "${path.module}/lambdas/validate"
  env_vars = {
    RAW_BUCKET = module.raw.bucket
  }
  dlq_arn = module.dlq.arn
}

module "enrich_fn" {
  source   = "./modules/lambda_fn"
  name     = "${var.project}-${var.env}-enrich"
  handler  = "handler.lambda_handler"
  runtime  = "python3.11"
  role_arn = module.etl_role.arn
  src_dir  = "${path.module}/lambdas/enrich"
  env_vars = {}
  dlq_arn  = module.dlq.arn
}

module "transform_fn" {
  source   = "./modules/lambda_fn"
  name     = "${var.project}-${var.env}-transform"
  handler  = "handler.lambda_handler"
  runtime  = "python3.11"
  role_arn = module.etl_role.arn
  src_dir  = "${path.module}/lambdas/transform"
  env_vars = {}
  dlq_arn  = module.dlq.arn
}

module "upload_fn" {
  source   = "./modules/lambda_fn"
  name     = "${var.project}-${var.env}-upload"
  handler  = "handler.lambda_handler"
  runtime  = "python3.11"
  role_arn = module.etl_role.arn
  src_dir  = "${path.module}/lambdas/upload"
  env_vars = { CURATED_BUCKET = module.curated.bucket }
  dlq_arn  = module.dlq.arn
}

module "sf" {
  source            = "./modules/step_functions"
  name              = "${var.project}-${var.env}-etl"
  role_arn          = module.etl_role.arn
  definition        = file("${path.module}/state_machines/etl.asl.json")
  lambda_arns_map = {
    Validate  = module.validate_fn.arn
    Enrich    = module.enrich_fn.arn
    Transform = module.transform_fn.arn
    Upload    = module.upload_fn.arn
  }
}

module "eb" {
  source      = "./modules/eventbridge_rule"
  name        = "${var.project}-${var.env}-trigger"
  description = "Kick ETL on schedule and on custom events"
  schedule_expression = var.schedule_expression
  target_arn  = module.sf.arn
}
