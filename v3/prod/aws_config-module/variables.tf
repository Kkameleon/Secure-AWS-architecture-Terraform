variable "prod_account_id" {
  type        = string
}

variable "config_name" {
  description = "The name of the AWS Config instance."
  type        = string
  default     = "aws-config"
}

variable "config_aggregator_name" {
  description = "The name of the aggregator."
  type        = string
  default     = "organization"
}

variable "aggregate_organization" {
  description = "Aggregate compliance data by organization"
  type        = bool
  default     = false
}

variable "config_logs_bucket" {
  description = "The S3 bucket for AWS Config logs. If you have set enable_config_recorder to false then this can be an empty string."
  type        = string
}

variable "config_logs_prefix" {
  description = "The S3 prefix for AWS Config logs."
  type        = string
  default     = "config"
}

variable "config_max_execution_frequency" {
  description = "The maximum frequency with which AWS Config runs evaluations for a rule."
  type        = string
  default     = "TwentyFour_Hours"
}

variable "config_delivery_frequency" {
  description = "The frequency with which AWS Config delivers configuration snapshots."
  default     = "Six_Hours"
  type        = string
}

variable "acm_days_to_expiration" {
  description = "Specify the number of days before the rule flags the ACM Certificate as noncompliant."
  type        = number
  default     = 14
}

variable "require_uppercase_characters" {
  description = "Require at least one uppercase character in password."
  type        = bool
  default     = false
}

variable "require_lowercase_characters" {
  description = "Require at least one lowercase character in password."
  type        = bool
  default     = false
}

variable "require_symbols" {
  description = "Require at least one symbol in password."
  type        = bool
  default     = false
}

variable "require_numbers" {
  description = "Require at least one number in password."
  type        = bool
  default     = false
}

variable "minimum_password_length" {
  description = "Password minimum length."
  type        = number
  default     = 14
}

variable "password_reuse_prevention" {
  description = "Number of passwords before allowing reuse."
  type        = number
  default     = 24
}

variable "max_password_age" {
  description = "Number of days before password expiration."
  type        = number
  default     = 90
}

variable "check_rds_public_access" {
  description = "Enable rds-instance-public-access-check rule"
  type        = bool
  default     = false
}

variable "check_cloudtrail_enabled" {
  description = "Enable cloudtrail-enabled rule"
  type        = bool
  default     = false
}

variable "check_cloud_trail_log_file_validation" {
  description = "Enable cloud-trail-log-file-validation-enabled rule"
  type        = bool
  default     = false
}

variable "check_required_tags" {
  description = "Enable required-tags rule"
  type        = bool
  default     = false
}

variable "required_tags_resource_types" {
  description = "Resource types to check for tags."
  type        = list(string)
  default     = []
}

variable "required_tags" {
  description = "A map of required resource tags. Format is tagNKey, tagNValue, where N is int. Values are optional."
  type        = map(string)
  default     = {}
}

variable "check_iam_password_policy" {
  description = "Enable iam-password-policy rule"
  type        = bool
  default     = false
}

variable "check_iam_group_has_users_check" {
  description = "Enable iam-group-has-users-check rule"
  type        = bool
  default     = false
}

variable "check_iam_user_no_policies_check" {
  description = "Enable iam-user-no-policies-check rule"
  type        = bool
  default     = false
}

variable "check_ec2_encrypted_volumes" {
  description = "Enable ec2-encrypted-volumes rule"
  type        = bool
  default     = false
}

variable "check_rds_storage_encrypted" {
  description = "Enable rds-storage-encrypted rule"
  type        = bool
  default     = false
}

variable "check_cloudwatch_log_group_encrypted" {
  description = "Enable cloudwatch-log-group-encryption rule"
  type        = bool
  default     = false
}

variable "check_cw_loggroup_retention_period" {
  description = "Enable cloudwatch-log-group-retention-period-check rule"
  type        = bool
  default     = false
}

variable "cw_loggroup_retention_period" {
  description = "Retention period for cloudwatch logs in number of days"
  type        = number
  default     = 3653
}

variable "check_restricted_ssh" {
  description = "Enable nacl-no-unrestricted-ssh-rdp rule"
  type        = bool
  default     = false
}

variable "check_backup_rds" {
  description = "Enable db-instance-backup-enabled rule"
  type        = bool
  default     = false
}

variable "check_rds-multi-az-support" {
  description = "Enable rds-multi-az-support rule"
  type        = bool
  default     = false
}

variable "check_public_subnets" {
  description = "Enable a custom subnet-auto-assign-public-ip-disabled rule"
  type        = bool
  default     = false
}

variable "check_s3_XX2X" {
  description = "Enable a custom XX2X s3 bucket rule"
  type        = bool
  default     = false
}

variable "check_s3_X22X" {
  description = "Enable a custom X22X s3 bucket rule"
  type        = bool
  default     = false
}

variable "check_s3_X33X" {
  description = "Enable a custom X33X s3 bucket rule"
  type        = bool
  default     = false
}

variable "check_s3_32XX" {
  description = "Enable a custom 32XX s3 bucket rule"
  type        = bool
  default     = false
}

variable "check_ec2_tags" {
  description = "Enable a custom tag rule on ec2"
  type        = bool
  default     = false
}

variable "check_rds_tags" {
  description = "Enable a custom tag rule on rds"
  type        = bool
  default     = false
}

variable "check_s3_tags" {
  description = "Enable a custom tag rule on s3"
  type        = bool
  default     = false
}

variable "check_subnets_tags" {
  description = "Enable a custom tag rule on subnets"
  type        = bool
  default     = false
}

variable "check_restricted_ssh_rdp_for_nacl" {
  description = "Enable the nacl-no-unrestricted-ssh-rdp for nacl"
  type        = bool
  default     = false
}



variable "notifiy_change_in_object_with_security_tag" {
  description = "Enable a rule that will send a notification when a change is made to an object with a security tag"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to AWS Config resources"
  type        = map(string)
  default     = {"Automation":"Terraform"}
}

variable "include_global_resource_types" {
  description = "Specifies whether AWS Config includes all supported types of global resources with the resources that it records."
  type        = bool
  default     = false
}

variable "config_sns_topic_arn" {
  description = "An SNS topic to stream configuration changes and notifications to."
  type        = string
  default     = null
}

variable "enable_config_recorder" {
  description = "Enables configuring the AWS Config recorder resources in this module."
  type        = bool
  default     = false
}

