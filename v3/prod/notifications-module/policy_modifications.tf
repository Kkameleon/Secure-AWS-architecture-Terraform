#############################
# POLICY MANAGEMENT NOTIFICATION BEGINNING
#############################

resource "aws_cloudwatch_event_rule" "policy_management_rule" {
  name          = "policy_management_rule"
  description   = "Creation or deletion of a policy"
  event_pattern = <<PATTERN
  {
    "source": [
        "aws.iam"
    ],
    "detail-type": [
        "AWS API Call via CloudTrail"
    ],
    "detail": {
        "eventName": [
            "CreatePolicy",
            "DeletePolicy"
        ]
    }
}
  PATTERN
}

resource "aws_cloudwatch_event_target" "sns_policy_management" {
  count     = var.send_sns ? 1 : 0
  rule      = aws_cloudwatch_event_rule.policy_management_rule.name
  target_id = "send-to-sns"
  arn       = data.aws_sns_topic.sns.arn

  input_transformer {
    input_template = "\"Creation or deletion of a policy.\""
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_cwe_triggered_policy_management" {
  alarm_name          = var.alarm_suffix == "" ? "policy_management_rule-alarm" : "policy_management_rule-alarm-${var.alarm_suffix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "TriggeredRules"
  namespace           = "AWS/Events"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "policy_management_rule CW Rule has been triggered"
  alarm_actions       = [data.aws_sns_topic.sns.arn]
  ok_actions          = [data.aws_sns_topic.sns.arn]

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.policy_management_rule.name
  }
}

#############################
# POLICY MANAGEMENT NOTIFICATION END
#############################