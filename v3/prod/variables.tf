variable "scp_bucket_id" {
  type = string
  default = "team-34-scp-bucket-wave-cloud-202220220315184331490500000001"
}

variable "region" {
  default = "eu-west-3"
}

variable "logs_s3_name" {
  type        = string
  default     = "secu-logs-teapot"
}

variable "topic_name" {
  type        = string
  default     = "the_topic"
}

variable "mail_notif" {
  type        = string
  default     = "kkameleon.deployment@gmail.com"
}

variable "config_name" {
  type        = string
  default     = "aws-config"
}

variable "log_retention_days" {
  type        = number
  default     = 180
}

variable "prod_account_id" {
  type        = string
  default     = "461141838153"
}

