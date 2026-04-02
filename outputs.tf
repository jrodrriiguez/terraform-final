output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "iam_user" {
  value = aws_iam_user.user.name
}