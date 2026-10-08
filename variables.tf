variable "account_alias" {
  description = "Short account identifier used in resource names"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "VPC whose default security group is locked down"
  type        = string
}

variable "mandatory_tags" {
  description = "Tags applied to every resource (enforced at plan time by convention)"
  type        = map(string)
  default = {
    Owner       = "platform-engineering"
    Environment = "shared"
  }
}

variable "monthly_budget_usd" {
  description = "Monthly cost budget that triggers the forecast alert"
  type        = string
  default     = "500"
}

variable "alarm_emails" {
  description = "Email endpoints subscribed to the alarms SNS topic"
  type        = list(string)
  default     = []
}
