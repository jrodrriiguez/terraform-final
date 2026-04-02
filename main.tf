provider "aws" {
  region = "us-east-1"
}

# -------------------------
# SNS Topic + Email
# -------------------------
resource "aws_sns_topic" "alerts" {
  name = "guardduty-alerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "jrodriguezterraform@gmail.com"
}

# -------------------------
# EventBridge Rule
# -------------------------
resource "aws_cloudwatch_event_rule" "guardduty_rule" {
  name = "guardduty-findings-rule"

  event_pattern = jsonencode({
    source = ["aws.guardduty"]
  })
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.alerts.arn
}

# Allow EventBridge to publish to SNS
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "sns:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# -------------------------
# IAM User
# -------------------------
resource "aws_iam_user" "user" {
  name = "test-user"
}

# -------------------------
# KMS Key
# -------------------------
resource "aws_kms_key" "key" {
  description             = "Test KMS Key"
  deletion_window_in_days = 7
}