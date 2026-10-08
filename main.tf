terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # backend configured per environment via -backend-config
}

provider "aws" {
  region = var.region
  default_tags {
    tags = merge(var.mandatory_tags, {
      ManagedBy = "terraform"
      Account   = var.account_alias
    })
  }
}

# --- Remote state backend (bootstrap once per account) ---
resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.account_alias}-tfstate"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "aws:kms" }
  }
}

resource "aws_dynamodb_table" "tflock" {
  name         = "${var.account_alias}-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# --- Baseline security: no open ingress anywhere ---
resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
  # intentionally empty: default SG allows nothing
  tags = { Name = "default-deny" }
}

# --- Centralized logging ---
resource "aws_kms_key" "logs" {
  description             = "CloudWatch Logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_cloudwatch_log_group" "platform" {
  name              = "/platform/${var.account_alias}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.logs.arn
}

# --- Alarms: SNS topic + monthly budget with forecast alert ---
resource "aws_sns_topic" "alarms" {
  name         = "${var.account_alias}-alarms"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "alarms_email" {
  for_each  = toset(var.alarm_emails)
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_budgets_budget" "monthly" {
  name         = "${var.account_alias}-monthly"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.alarm_emails
  }
}
