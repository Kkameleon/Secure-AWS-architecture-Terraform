# Variables globales
variable "region" {
  default = "eu-west-3"
}

variable "availability_zone" {
  type = list(string)
  default = ["eu-west-3a", "eu-west-3b"]
}

variable "topic_name" {
  type        = string
  default     = "the_topic"
}

variable "logs_s3_name" {
  type        = string
  default     = "secu-logs-teapot"
}

variable "prod_account_id" {
  type        = string
  default     = "461141838153"
}
