# SCP : module to manage SCP
module "scp" {
  source = "./scp-module"

  scp_bucket_id                   = var.scp_bucket_id

  tags = {
    "Automation"                  = "Terraform"
    "Security"                    = "High"
  }
}



# Setup of the break_glass user and management of the notification when he logs into his acccount
# A pgp key has been created with the following commands :
# gpg --batch --gen-key key_template
# gpg --output public-key-binary-break_glass.gpg --export kkameleon.deployment@gmail.com
# Password of the key is "pgp" for demonstration purpose
# This allows us to get the break_glass_encrypted_password when deploying
module "break_glass" {
  source = "./break_glass-module"

}

# IAM : user and access management resources
module "iam" {
  source = "./iam-module"

  minimum_password_length           = 14
  require_lowercase_characters      = true
  require_numbers                   = true
  require_uppercase_characters      = true
  require_symbols                   = true

  allow_users_to_change_password    = true
  max_password_age                  = 90

  depends_on = [
    module.break_glass
  ]

  tags = {
    "Automation"                    = "Terraform"
    "Security"                      = "High"
  }
}

# Module to enforce MFA for the given groups
module "mfa" {
  source = "./mfa-module"

  groups                            = module.iam.all_groups_names

  depends_on                        = [module.iam]

  tags = {
    "Automation"                    = "Terraform"
    "Security"                      = "High"
  }

}





# AWS Budgets
# Monitoring the budget
module "budget" {
  source = "./budget-module"

  budget_limit_amount               = 25
  notification_threshold            = ["50", "90","100"]
  notification_type                 = "ACTUAL"
  notification_emails               = ["kkameleon.deployment@gmail.com"]

  groups                            = module.iam.all_groups_names

  depends_on                        = [module.iam]

  tags = {
    "Automation"                    = "Terraform"
    "Security"                      = "High"
  }
}





# -----------------------------------------------------------
# Cloudtrail  ---generate-events--->   EventBridge   ---filter-events--->   CloudWatch  ---trigger-alarm-and-notify--->  SNS Topic
# -----------------------------------------------------------


# SNS : a Simple notification service
module "sns_topic" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 3.0"

  name    = var.topic_name
}

# SUBSCRIPTION to the SNS (mail)
# You need to confirm the email so you can receive the notifications of the topic created
# You could easily change this to a phone number if you don't want to confirm a mail each time you deploy
resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = module.sns_topic.sns_topic_arn
  protocol  = "email"
  endpoint  = var.mail_notif
}


# AWS Cloudtrail
# Enable the trail in our region so we can deal with the events
module "aws_cloudtrail" {
  source = "trussworks/cloudtrail/aws"

  s3_bucket_name            = var.logs_s3_name
  log_retention_days        = var.log_retention_days
  enabled                   = true

  tags = {
    "Automation"            = "Terraform",
    "Security"              = "High"
  }
}


# AWS Cloudwatch & AWS EventBridge
module "notifications" {
  source                    = "./notifications-module"

  sns_topic_name            = var.topic_name
  send_sns                  = true
  alarm_suffix              = ""

  depends_on                = [module.sns_topic.sns_topic_arn]

  tags = {
    "Automation"            = "Terraform"
    "Security"              = "High"
  }
}


# Cloudwatch-logs-exporter
# Export everyday at 12h15, the cloudwatch logs to the s3 log bucket
# This module is based on gadgetry-io/cloudwatch-logs-exporter/aws
# Modified so we can export several log groups without recreating unuseful resources,
# such as the iam_role able to export the data
module "cloudwatch-logs-exporter" {
  source            = "./cloudwatch-logs-exporter-module"

  names             = ["cloudtrail-events"]
  log_groups        = ["cloudtrail-events"]
  s3_bucket         = var.logs_s3_name
  s3_prefixes       = ["cw/cloudtrail-events"]
}











# AWS CONFIG
# Be aware this costs a lot
# Forked from trussworks/terraform-aws-config and heavily modified
module "aws_config" {
  source = "./aws_config-module"

  config_name                               = var.config_name
  config_logs_bucket                        = var.logs_s3_name
  config_logs_prefix                        = "config"
  config_sns_topic_arn                      = module.sns_topic.sns_topic_arn
  enable_config_recorder                    = true
  prod_account_id                           = var.prod_account_id

# IAM
# -----------------------------------------------------------------------------

  minimum_password_length                   = 14
  max_password_age                          = 90
  require_lowercase_characters              = true
  require_numbers                           = true
  require_uppercase_characters              = true
  require_symbols                           = true

  # Ensure the account password policy for IAM users meets the specified requirements
  check_iam_password_policy                 = true

  # Checks whether IAM groups have at least one IAM user.
  check_iam_group_has_users_check           = false

  # Ensure that none of your IAM users have policies attached. IAM users must inherit permissions from IAM groups or roles.
  check_iam_user_no_policies_check          = true


# CLOUDWATCH
# -----------------------------------------------------------------------------

  # Checks whether Amazon CloudWatch LogGroup retention period is set to specific number of days. 
  # The rule is NON_COMPLIANT if the retention period is not set or is less than the configured retention period.
  check_cw_loggroup_retention_period        = true
  cw_loggroup_retention_period              = var.log_retention_days


# EC2
# -----------------------------------------------------------------------------

  # Checks if the incoming SSH traffic for the security groups is accessible. 
  # The rule is COMPLIANT when IP addresses of the incoming SSH traffic in the security groups are restricted (CIDR other than 0.0.0.0/0). 
  # This rule applies only to IPv4.
  # This has a remediation attached
  check_restricted_ssh                      = true   
  
  # Checks if default ports for SSH/RDP ingress traffic for network access control lists (NACLs) is unrestricted. 
  # The rule is NON_COMPLIANT if a NACL inbound entry allows a source CIDR block of '0.0.0.0/0' or '::/0' for ports 22 or 3389. 
  check_restricted_ssh_rdp_for_nacl         = true 


  # Checks if Amazon Virtual Private Cloud (Amazon VPC) subnets are assigned a public IP address. 
  # This rule is NON_COMPLIANT if Amazon VPC has subnets that are assigned a public IP address without having the public exposition tag.
  check_public_subnets                      = true


  check_ec2_encrypted_volumes               = true


# RDS
# -----------------------------------------------------------------------------

  # Checks whether storage encryption is enabled for your RDS DB instances.
  check_rds_storage_encrypted               = true

  # Checks whether RDS DB instances have backups enabled.
  check_backup_rds                          = true

  # Checks whether high availability is enabled for your RDS DB instances.
  check_rds-multi-az-support                = true

 
# S3
# -----------------------------------------------------------------------------

  # Checks if >XX2X S3 buckets buckets are publicly accessible. 
  # This rule is NON_COMPLIANT if an  >XX2X S3 bucket is not listed in the excludedPublicBuckets parameter and bucket level settings are public.
  # This has a remediation attached
  check_s3_XX2X                             = true

  # Checks that your >X22X S3 bucket either has S3 default encryption enabled 
  # or that the >X22X S3 bucket policy explicitly denies put-object requests without server side encryption.
  # This has a remediation attached
  check_s3_X22X                             = true

  # Checks whether the >X33X S3 buckets are encrypted with AWS Key Management Service(AWS KMS). 
  # The rule is NON_COMPLIANT if the >X33X S3 bucket is not encrypted with AWS KMS key.
  check_s3_X33X                             = true

  # Checks whether >32XX S3 bucket has lock and versioning enabled, by default. 
  # The rule is NON_COMPLIANT if the lock or versioning is not enabled.
  # This has a remediation attached (only on versioning)
  check_s3_32XX                             = true

# Tags
# -----------------------------------------------------------------------------
  # This has a remediation attached
  check_s3_tags                             = true

  check_subnets_tags                        = true

  check_rds_tags                            = true

  check_ec2_tags                            = true

  notifiy_change_in_object_with_security_tag= true


  tags = {
    "Automation"            = "Terraform"
    "Name"                  =  var.config_name
    "Security"              = "High"
  }
}