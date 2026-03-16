locals {
  aws_account_id  = data.aws_caller_identity.current.account_id
  data_bucket_name = lower("${var.application}-${var.service}-data-files-${var.aws_env}")
}

# S3 Bucket for application data
module "data_bucket" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.6.1"
  bucket  = local.data_bucket_name
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.application}-${var.service}-lambda-execution-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy" "policy" {
  name   = "${var.application}-${var.service}-lambda-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = local.policy
}

module "data_table" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table.git//"

  name         = "app-data-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "phone_number"
  range_key    = "date"

  server_side_encryption_enabled = true
  deletion_protection_enabled    = var.deletion_protection_enabled
  point_in_time_recovery_enabled = var.point_in_time_recovery

  attributes = [
    {
      name = "phone_number"
      type = "S"
    },
    {
      name = "date"
      type = "S"
    },
    {
      name = "name"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "name-index"
      hash_key        = "name"
      range_key       = "date"
      projection_type = "ALL"
      read_capacity   = 0
      write_capacity  = 0
    }
  ]

  tags = {
    Application = var.application
    Service     = var.service
    Environment = var.aws_env
  }
}

module "ssm_params" {
  source = "terraform-aws-modules/ssm-parameter/aws"
  parameters = {
    lambda_role = {
      name  = "/${var.application}/${var.service}/lambda_role"
      value = aws_iam_role.lambda_execution_role.arn
    }
    data_bucket = {
      name  = "/${var.application}/data_bucket"
      value = module.data_bucket.s3_bucket_id
    }
    data_table = {
      name  = "/${var.application}/data_table"
      value = module.data_table.dynamodb_table_id
    }
  }
}

