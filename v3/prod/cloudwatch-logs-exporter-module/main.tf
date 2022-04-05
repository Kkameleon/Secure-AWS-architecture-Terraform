resource "null_resource" "download_lambda_zip" {
  triggers = {
    version = var.exporter_version
  }

  provisioner "local-exec" {
    command = "curl -L -o ${path.module}/lambda-cloudwatch-export_${var.exporter_version}_linux_amd64.zip https://github.com/gadgetry-io/lambda-cloudwatch-export/releases/download/v${var.exporter_version}/lambda-cloudwatch-export_${var.exporter_version}_linux_amd64.zip"
  }
}

resource "aws_lambda_function" "cloudwatch_export" {
  count = length(var.names)
  function_name = var.names[count.index]
  filename      = "${path.module}/lambda-cloudwatch-export_${var.exporter_version}_linux_amd64.zip"
  role          = aws_iam_role.cloudwatch_export.arn
  handler       = "cloudwatch-export"
  runtime       = "go1.x"

  environment {
    variables = {
      environment = terraform.workspace
    }
  }

  depends_on = [null_resource.download_lambda_zip]
}

resource "aws_cloudwatch_event_rule" "cloudwatch_export" {
  count = length(var.names)
  name                = [for k, v in aws_lambda_function.cloudwatch_export : v.function_name][count.index]
  description         = "CloudWatch log exports for ${var.log_groups[count.index]}"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "lambda" {
  count = length(var.names)
  target_id = [for k, v in aws_lambda_function.cloudwatch_export : v.function_name][count.index]
  rule      = [for k, v in aws_cloudwatch_event_rule.cloudwatch_export : v.name][count.index]
  
  arn       = [for k, v in aws_lambda_function.cloudwatch_export : v.arn][count.index]

  input = <<EOF
{"s3_bucket":"${var.s3_bucket}", "s3_prefix":"${var.s3_prefixes[count.index]}", "log_group":"${var.log_groups[count.index]}"}
EOF
}

resource "aws_lambda_permission" "events" {
  count = length(var.names)
  statement_id  = [for k, v in aws_lambda_function.cloudwatch_export : v.function_name][count.index]
  action        = "lambda:InvokeFunction"
  function_name = [for k, v in aws_lambda_function.cloudwatch_export : v.function_name][count.index]
  principal     = "events.amazonaws.com"
  
  source_arn    = [for k, v in aws_cloudwatch_event_rule.cloudwatch_export : v.arn][count.index]
}

resource "aws_iam_role" "cloudwatch_export" {
  name               = var.names[0]
  description        = "Lambda role for CloudWatch Log exports"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_export_assume_role.json
}

data "aws_iam_policy_document" "cloudwatch_export_assume_role" {
  statement {
    sid     = "BasicLambdaExecution"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "cloudwatch_export" {
  name   = var.names[0]
  role   = aws_iam_role.cloudwatch_export.id
  policy = data.aws_iam_policy_document.cloudwatch_export_inline.json
}

data "aws_iam_policy_document" "cloudwatch_export_inline" {
  statement {
    actions   = ["cloudwatch:*", "logs:*"]
    resources = ["*"]
  }
}