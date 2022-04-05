output "aws_config_role_arn" {
  description = "The ARN of the AWS config role."
  value       = concat(aws_iam_role.main.*.arn, [""])[0]
}

output "aws_config_role_name" {
  description = "The name of the IAM role used by AWS config"
  value       = concat(aws_iam_role.main.*.name, [""])[0]
}