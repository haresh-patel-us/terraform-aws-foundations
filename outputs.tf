output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}

output "tflock_table" {
  value = aws_dynamodb_table.tflock.name
}

output "platform_log_group" {
  value = aws_cloudwatch_log_group.platform.name
}

output "alarms_topic_arn" {
  value = aws_sns_topic.alarms.arn
}
