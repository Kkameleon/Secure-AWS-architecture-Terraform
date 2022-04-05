# Creates a AWS Budget for the overall cost of the account
resource "aws_budgets_budget" "overall_budget_cost_email_notification" {
  name              = "budget-cost-alerts"
  budget_type       = "COST"
  limit_amount      = var.budget_limit_amount
  limit_unit        = var.budget_limit_unit
  time_period_start = "2022-03-23_00:00"
  time_unit         = var.budget_time_unit

  cost_types {
    # List of available cost types: 
    # https://docs.aws.amazon.com/aws-cost-management/latest/APIReference/API_budgets_CostTypes.html
    include_credit = var.cost_type_include_credit
    include_discount = var.cost_type_include_discount
    include_other_subscription = var.cost_type_include_other_subscription
    include_recurring = var.cost_type_include_recurring
    include_refund = var.cost_type_include_refund
    include_subscription = var.cost_type_include_subscription
    include_support = var.cost_type_include_support
    include_tax = var.cost_type_include_tax
    include_upfront = var.cost_type_include_upfront
    use_amortized = var.cost_type_use_amortized
    use_blended = var.cost_type_use_blended
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.notification_threshold[0]
    threshold_type             = "PERCENTAGE"
    notification_type          = var.notification_type
    subscriber_email_addresses = var.notification_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.notification_threshold[1]
    threshold_type             = "PERCENTAGE"
    notification_type          = var.notification_type
    subscriber_email_addresses = var.notification_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.notification_threshold[2]
    threshold_type             = "PERCENTAGE"
    notification_type          = var.notification_type
    subscriber_email_addresses = var.notification_emails
  }
}


# resource "aws_budgets_budget_action" "restriction" {
#   budget_name        = aws_budgets_budget.overall_budget_cost_email_notification.name
#   action_type        = "APPLY_IAM_POLICY"
#   approval_model     = "AUTOMATIC"
#   notification_type  = "ACTUAL"
#   execution_role_arn = aws_iam_role.budget_execution_role.arn

#   action_threshold {
#     action_threshold_type  = "PERCENTAGE"
#     action_threshold_value = 100
#   }

#   definition {
#     iam_action_definition {
#       policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
#       groups     = var.groups
#     }
#   }

#   subscriber {
#     address           = var.notification_emails[0]
#     subscription_type = "EMAIL"
#   }

# }


data "aws_partition" "current" {}

resource "aws_iam_role" "budget_execution_role" {
  name = "budget_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "budgets.${data.aws_partition.current.dns_suffix}"
        ]
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}

