#############################
# BREAK_GLASS NOTIFICATION BEGINNING
#############################

resource "aws_cloudwatch_event_rule" "break_glass_sign_in_rule" {
  name          = "iam-break_glass-login"
  description   = "Successful login with break_glass account"
  event_pattern = <<PATTERN
  {
    "detail": {
      "userIdentity": {
        "type": ["IAMUser"],
        "userName": ["break_glass"]
      }
    },
    "detail-type": [
      "AWS Console Sign In via CloudTrail"
    ]
  }
  PATTERN
}

resource "aws_cloudwatch_event_target" "sns_break_glass" {
  count     = var.send_sns ? 1 : 0
  rule      = aws_cloudwatch_event_rule.break_glass_sign_in_rule.name
  target_id = "send-to-sns"
  arn       = data.aws_sns_topic.sns.arn

  input_transformer {
    input_template = "\"Successful AWS console login with the break_glass account.\""
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_cwe_triggered_break_glass" {
  alarm_name          = var.alarm_suffix == "" ? "iam-break_glass-login-alarm" : "iam-break_glass-login-alarm-${var.alarm_suffix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "TriggeredRules"
  namespace           = "AWS/Events"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "IAM break_glass Login CW Rule has been triggered"
  alarm_actions       = [data.aws_sns_topic.sns.arn]
  ok_actions          = [data.aws_sns_topic.sns.arn]

  dimensions = {
    RuleName = aws_cloudwatch_event_rule.break_glass_sign_in_rule.name
  }
}

#############################
# BREAK_GLASS NOTIFICATION END
#############################