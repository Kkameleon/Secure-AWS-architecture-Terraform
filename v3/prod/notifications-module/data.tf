data "aws_partition" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_sns_topic" "sns" {
  name = var.sns_topic_name
}