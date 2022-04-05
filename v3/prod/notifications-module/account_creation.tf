#############################
# ACCOUNT CREATION NOTIFICATION BEGINNING
#############################

resource "aws_cloudwatch_event_rule" "account_creation_rule" {
  name          = "account_creation_rule"
  description   = "Creation of an account"
  event_pattern = <<PATTERN
  {
    "source": [
        "aws.iam"
    ],
    "detail-type": [
        "AWS API Call via CloudTrail"
    ],
    "detail": {
        "eventSource": [
            "iam.amazonaws.com"
        ],
        "eventName": [
            "CreateUser"
        ]
    }
}
  PATTERN
}

resource "aws_cloudwatch_event_target" "sns_account_creation" {
  count     = var.send_sns ? 1 : 0
  rule      = aws_cloudwatch_event_rule.account_creation_rule.name
  target_id = "send-to-sns"
  arn       = data.aws_sns_topic.sns.arn

  input_transformer {
    input_template = "\"Successful creation of a new user.\""
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_cwe_triggered_account_creation" {
  alarm_name          = var.alarm_suffix == "" ? "account_creation_rule-alarm" : "account_creation_rule-alarm-${var.alarm_suffix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "TriggeredRules"
  namespace           = "AWS/Events"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "account_creation_rule CW Rule has been triggered"
  alarm_actions       = [data.aws_sns_topic.sns.arn]
  ok_actions          = [data.aws_sns_topic.sns.arn]

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.account_creation_rule.name
  }
}

#############################
# ACCOUNT CREATION NOTIFICATION END
#############################