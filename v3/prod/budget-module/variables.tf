variable "groups" {
  description = "When breaching budget, restric policy of these groups"
  type        = list(string)
  default     = []
}

variable "budget_limit_amount" {
  description = "The amount for the budget alert."
  type = string
  default = "100"
}

variable "budget_limit_unit" {
  description = "The currency used for the budget, such as USD or GB."
  type = string
  default = "USD"
}

variable "budget_time_unit" {
  description = "The length of time until a budget resets the actual and forecasted spend, Valid values: MONTHLY, QUARTERLY, ANNUALLY."
  type = string
  default = "MONTHLY"
}

variable "notification_threshold" {
  description = "Threshold when the notification should be sent"
  type = list(string)
  default = ["50","100"]
}

variable "notification_type" {
  description = "What kind of budget value to notify on. Can be ACTUAL or FORECASTED"
  type = string
  default = "ACTUAL"
}

variable "notification_emails" {
  description = "List of email addresses to send budget notifications too"
  type    = list(string)
}

variable "cost_type_include_credit" {
  description = "A boolean value whether to include credits in the cost budget."
  type        = string
  default     = "true"
}

variable "cost_type_include_discount" {
  description = "Specifies whether a budget includes discounts."
  type        = string
  default     = "true"
}

variable "cost_type_include_other_subscription" {
  description = "A boolean value whether to include other subscription costs in the cost budget."
  type        = string
  default     = "true"
}

variable "cost_type_include_recurring" {
  description = "A boolean value whether to include recurring costs in the cost budget."
  type        = string
  default     = "true"
}

variable "cost_type_include_refund" {
  description = "A boolean value whether to include refunds in the cost budget."
  type        = string
  default     = "true"
}

variable "cost_type_include_subscription" {
  description = "A boolean value whether to include subscriptions in the cost budget."
  type        = string
  default     = "true"
}

variable "cost_type_include_support" {
  description = "A boolean value whether to include support costs in the cost budget."
  type        = string
  default     = "true"
}

variable "cost_type_include_tax" {
  description = "A boolean value whether to include support costs in the cost budget."
  type        = string
  default     = "true"
}

variable "cost_type_include_upfront" {
  description = "A boolean value whether to include support costs in the cost budget."
  type        = string
  default     = "true"
}

variable "cost_type_use_amortized" {
  description = "Specifies whether a budget uses the amortized rate."
  type        = string
  default     = "false"
}

variable "cost_type_use_blended" {
  description = "A boolean value whether to use blended costs in the cost budget."
  type        = string
  default     = "false"
}

variable "tags" {
  description = "A mapping of tags to budget resources."
  default     = { Automation = "Terraform" }
  type        = map(string)
}