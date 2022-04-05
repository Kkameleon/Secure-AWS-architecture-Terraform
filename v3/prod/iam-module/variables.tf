variable "allow_users_to_change_password" {
  type        = bool
  default     = true
  description = "Whether to allow users to change their own password"
}

variable "hard_expiry" {
  type        = string
  default     = false
  description = "Whether users are prevented from setting a new password after their password"
}

variable "max_password_age" {
  type        = number
  default     = 90
  description = "The number of days that an user password is valid."
}

variable "minimum_password_length" {
  type        = number
  default     = 14
  description = "Minimum length to require for user passwords."
}

variable "password_reuse_prevention" {
  type        = number
  default     = 24
  description = "The number of previous passwords that users are prevented from reusing."
}

variable "require_lowercase_characters" {
  type        = bool
  default     = true
  description = "Whether to require lowercase characters for user passwords."
}

variable "require_numbers" {
  type        = bool
  default     = true
  description = "Whether to require numbers for user passwords."
}

variable "require_symbols" {
  type        = bool
  default     = true
  description = "Whether to require symbols for user passwords."
}

variable "require_uppercase_characters" {
  type        = bool
  default     = true
  description = "Whether to require uppercase characters for user passwords."
}

variable "tags" {
  description = "A mapping of tags to iam resources."
  default     = { Automation = "Terraform" }
  type        = map(string)
}