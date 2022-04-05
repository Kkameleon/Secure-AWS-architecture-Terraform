variable "alarm_suffix" {
  type        = string
  default     = ""
  description = "Suffix to add to alarm name, used for separating different AWS account."
}

variable "sns_topic_name" {
  type        = string
  description = "The name of the SNS topic to send notifications."
}

variable "send_sns" {
  type        = bool
  default     = false
  description = "If true will send message to SNS topic"
}

variable "tags" {
  description = "A mapping of tags to notifications resources."
  default     = { Automation = "Terraform" }
  type        = map(string)
}