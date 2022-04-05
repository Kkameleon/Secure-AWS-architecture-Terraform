locals {
  aws_config_iam_password_policy = templatefile("./${path.module}/config-policies/iam-password-policy.tpl",
    {
      password_require_uppercase = var.require_uppercase_characters ? "true" : "false"
      password_require_lowercase = var.require_lowercase_characters ? "true" : "false"
      password_require_symbols   = var.require_symbols ? "true" : "false"
      password_require_numbers   = var.require_numbers ? "true" : "false"
      password_min_length        = var.minimum_password_length
      password_reuse_prevention  = var.password_reuse_prevention
      password_max_age           = var.max_password_age
    }
  )

  aws_config_acm_certificate_expiration = templatefile("./${path.module}/config-policies/acm-certificate-expiration.tpl",
    {
      acm_days_to_expiration = var.acm_days_to_expiration
    }
  )



  aws_config_cloudwatch_log_group_retention_period = templatefile("./${path.module}/config-policies/cloudwatch-log-retention.tpl",
    {
      cw_loggroup_retention_period = var.cw_loggroup_retention_period
    }
  )
}

#
# AWS Config Rules
#


# IAM
# -----------------------------------------------------------------------------

resource "aws_config_config_rule" "iam-password-policy" {
  count            = var.check_iam_password_policy ? 1 : 0
  name             = "iam-password-policy"
  description      = "Ensure the account password policy for IAM users meets the specified requirements"
  input_parameters = local.aws_config_iam_password_policy

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  maximum_execution_frequency = var.config_max_execution_frequency

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "iam-user-no-policies-check" {
  count       = var.check_iam_user_no_policies_check ? 1 : 0
  name        = "iam-user-no-policies-check"
  description = "Ensure that none of your IAM users have policies attached. IAM users must inherit permissions from IAM groups or roles."

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_NO_POLICIES_CHECK"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "iam-group-has-users-check" {
  count       = var.check_iam_group_has_users_check ? 1 : 0
  name        = "iam-group-has-users-check"
  description = "Checks whether IAM groups have at least one IAM user."

  source {
    owner             = "AWS"
    source_identifier = "IAM_GROUP_HAS_USERS_CHECK"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}


# CLOUDWATCH
# -----------------------------------------------------------------------------

resource "aws_config_config_rule" "cw_loggroup_retention_period_check" {
  count = var.check_cw_loggroup_retention_period ? 1 : 0

  name        = "cloudwatch_log_group-retention"
  description = "Checks whether Amazon CloudWatch LogGroup retention period is set to specific number of days. The rule is NON_COMPLIANT if the retention period is not set or is less than the configured retention period."

  input_parameters = local.aws_config_cloudwatch_log_group_retention_period

  source {
    owner             = "AWS"
    source_identifier = "CW_LOGGROUP_RETENTION_PERIOD_CHECK"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}


# EC2
# -----------------------------------------------------------------------------

resource "aws_config_config_rule" "restricted_ssh" {
  count = var.check_restricted_ssh ? 1 : 0

  name        = "restricted-ssh"
  description = "Checks if the incoming SSH traffic for the security groups is accessible. The rule is COMPLIANT when IP addresses of the incoming SSH traffic in the security groups are restricted (CIDR other than 0.0.0.0/0). This rule applies only to IPv4."

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "restricted_ssh_rdp_for_nacl" {
  count = var.check_restricted_ssh_rdp_for_nacl ? 1 : 0

  name        = "nacl-no-unrestricted-ssh-rdp"
  description = "Checks if default ports for SSH/RDP ingress traffic for network access control lists (NACLs) is unrestricted. The rule is NON_COMPLIANT if a NACL inbound entry allows a source CIDR block of '0.0.0.0/0' or '::/0' for ports 22 or 3389. "

  source {
    owner             = "AWS"
    source_identifier = "NACL_NO_UNRESTRICTED_SSH_RDP"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}


resource "aws_config_config_rule" "public_subnets" {
  count = var.check_public_subnets ? 1 : 0

  name        = "rds-multi-az-support"
  description = "Checks if Amazon Virtual Private Cloud (Amazon VPC) subnets are assigned a public IP address. This rule is NON_COMPLIANT if Amazon VPC has subnets that are assigned a public IP address without having the public exposition tag."

  source {
    owner             = "AWS"
    source_identifier = "SUBNET_AUTO_ASSIGN_PUBLIC_IP_DISABLED"
  }

  scope {
      tag_key = "exposition"
      tag_value = "private"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]

}

resource "aws_config_config_rule" "ec2-encrypted-volumes" {
  count       = var.check_ec2_encrypted_volumes ? 1 : 0
  name        = "ec2-volumes-must-be-encrypted"
  description = "Evaluates whether EBS volumes that are in an attached state are encrypted. Optionally, you can specify the ID of a KMS key to use to encrypt the volume."

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

# RDS
# -----------------------------------------------------------------------------

resource "aws_config_config_rule" "rds-storage-encrypted" {
  count       = var.check_rds_storage_encrypted ? 1 : 0
  name        = "rds-storage-encrypted"
  description = "Checks whether storage encryption is enabled for your RDS DB instances."

  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "backup_rds" {
  count = var.check_backup_rds ? 1 : 0

  name        = "db-instance-backup-enabled"
  description = "Checks whether RDS DB instances have backups enabled."

  source {
    owner             = "AWS"
    source_identifier = "DB_INSTANCE_BACKUP_ENABLED"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "rds-multi-az-support" {
  count = var.check_backup_rds ? 1 : 0

  name        = "rds-multi-az-support"
  description = "Checks whether high availability is enabled for your RDS DB instances."

  source {
    owner             = "AWS"
    source_identifier = "RDS_MULTI_AZ_SUPPORT"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}



# S3
# -----------------------------------------------------------------------------

resource "aws_config_config_rule" "s3_XX2X" {
  count = var.check_s3_XX2X ? 1 : 0

  name        = "s3-bucket-level-public-access-prohibited"
  description = "Checks if >XX2X S3 buckets are publicly accessible. This rule is NON_COMPLIANT if an Amazon S3 bucket is not listed in the excludedPublicBuckets parameter and bucket level settings are public."

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"
  }

  scope {
      tag_key = "XX2X"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "s3_X22X" {
  count = var.check_s3_X22X ? 1 : 0

  name        = "s3-bucket-server-side-encryption-enabled"
  description = "Checks that your >X22X S3 bucket either has S3 default encryption enabled or that the  >X22X S3 bucket policy explicitly denies put-object requests without server side encryption."

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  scope {
      tag_key = "X22X"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "s3_X33X" {
  count = var.check_s3_X33X ? 1 : 0

  name        = "s3-default-encryption-kms"
  description = "Checks whether the >X33X S3 buckets are encrypted with AWS Key Management Service(AWS KMS). The rule is NON_COMPLIANT if the >X33X S3 bucket is not encrypted with AWS KMS key."

  source {
    owner             = "AWS"
    source_identifier = "S3_DEFAULT_ENCRYPTION_KMS"
  }

  scope {
      tag_key = "X33X"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}


resource "aws_config_config_rule" "s3_32XX_versioning" {
  count = var.check_s3_32XX ? 1 : 0

  name        = "s3-bucket-versioning-enabled"
  description = "Checks whether versioning is enabled for your >32XX S3 buckets."

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  scope {
      tag_key = "32XX"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "s3_32XX_lock" {
  count = var.check_s3_32XX ? 1 : 0

  name        = "s3-bucket-default-lock-enabled"
  description = "Checks whether >32XX S3 bucket has lock enabled, by default. The rule is NON_COMPLIANT if the lock is not enabled."

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_DEFAULT_LOCK_ENABLED"
  }

  scope {
      tag_key = "32XX"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}


# Tags
# -----------------------------------------------------------------------------


resource "aws_config_config_rule" "required_s3_tags" {
  count       = var.check_s3_tags ? 1 : 0
  name        = "required_s3_tags"
  description = "Checks if resources are deployed with configured tags."

  scope {
    compliance_resource_types = ["S3::Bucket"]
  }

  input_parameters = jsonencode(
    {
    tag1Key   = "Availability"
    tag1Value = "1,2,3,4"
    tag2Key   = "Integrity"
    tag2Value = "1,2,3,4"
    tag3Key   = "Confidentiality"
    tag3Value = "1,2,3,4"
    tag4Key   = "Tracability"
    tag4Value = "1,2,3,4"
  }
  )

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "required_ec2_tags" {
  count       = var.check_ec2_tags ? 1 : 0
  name        = "required_ec2_tags"
  description = "Checks if resources are deployed with configured tags."

  scope {
    compliance_resource_types = [
      "EC2::CustomerGateway",
      "EC2::Instance",
      "EC2::InternetGateway",
      "EC2::NetworkAcl",
      "EC2::NetworkInterface",
      "EC2::RouteTable",
      "EC2::SecurityGroup",
      "EC2::Subnet",
      "EC2::Volume",
      "EC2::VPC",
      "EC2::VPNConnection",
      "EC2::VPNGateway"
      ]
  }

  input_parameters = jsonencode(
    {
    tag1Key   = "env"
    tag1Value = "dev,prod,preprod"
    tag2Key   = "metier"
    
  }
  )

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "required_rds_tags" {
  count       = var.check_rds_tags ? 1 : 0
  name        = "equired_rds_tags"
  description = "Checks if resources are deployed with configured tags."

  scope {
    compliance_resource_types = [
      "RDS::DBInstance",
      "RDS::DBSecurityGroup",
      "RDS::DBSnapshot",
      "RDS::DBSubnetGroup",
      "RDS::EventSubscription"
    ]
  }

  input_parameters = jsonencode(
    {
    tag1Key   = "env"
    tag1Value = "dev,prod,preprod"
    tag2Key   = "metier"
    
  }
  )

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "required_subnets_tags" {
  count       = var.check_subnets_tags ? 1 : 0
  name        = "required_subnets_tags"
  description = "Checks if resources are deployed with configured tags."

  scope {
    compliance_resource_types = ["EC2::Subnet"]
  }

  input_parameters = jsonencode(
    {
    tag1Key   = "exposition"
    tag1Value = "public,private"
    
  }
  )

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "notifiy_change_in_object_with_security_tag" {
  count       = var.notifiy_change_in_object_with_security_tag ? 1 : 0
  name        = "required_subnets_tags"
  description = "Checks if resources are deployed with configured tags."

  scope {
    compliance_resource_types = ["EC2::Subnet"]
  }

  input_parameters = jsonencode(
    {
    tag1Key   = "exposition"
    tag1Value = "public,private"
    
  }
  )

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  tags = var.tags

  depends_on = [aws_config_configuration_recorder.main]
}


