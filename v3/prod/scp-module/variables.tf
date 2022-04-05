variable "scp_bucket_id" {
  type = string
}

variable "tags" {
  description = "A mapping of tags to scp resources."
  default     = { Automation = "Terraform" }
  type        = map(string)
}