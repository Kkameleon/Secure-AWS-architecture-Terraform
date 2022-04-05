# EC2
# -----------------------------------------------------------------------------

resource "aws_config_remediation_configuration" "SSHRDPRemediation" {
  count = var.check_restricted_ssh ? 1 : 0
  config_rule_name = aws_config_config_rule.restricted_ssh[count.index].name
  resource_type    = "AWS::EC2::SecurityGroup"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-DisablePublicAccessForSecurityGroup"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = "arn:aws:iam::${var.prod_account_id}:role/security_config"
  }
  
  parameter {
    name           = "GroupId"
    resource_value = "RESOURCE_ID"
  }
  
  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 30

}

# S3
# -----------------------------------------------------------------------------

#
# AWS Config auto-remediation for bucket public access
#
resource "aws_config_remediation_configuration" "BucketPublicRemediation" {
  count = var.check_s3_XX2X ? 1 : 0
  config_rule_name = aws_config_config_rule.s3_XX2X[count.index].name
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWSConfigRemediation-ConfigureS3BucketPublicAccessBlock"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = "arn:aws:iam::${var.prod_account_id}:role/security_config"
  }
  
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }
  
  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 30

}



#
# AWS Config auto-remediation for bucket server-side encryption
#
resource "aws_config_remediation_configuration" "BucketSSERemediation" {
  count = var.check_s3_X22X ? 1 : 0
  config_rule_name = aws_config_config_rule.s3_X22X[count.index].name
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-EnableS3BucketEncryption"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = "arn:aws:iam::${var.prod_account_id}:role/security_config"
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }
  parameter {
    name         = "SSEAlgorithm"
    static_value = "AES256"
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 30

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = 25
      error_percentage                     = 20
    }
  }
}


#
# AWS Config auto-remediation for bucket versioning
#

resource "aws_config_remediation_configuration" "BucketVersioningRemediation" {
  count = var.check_s3_32XX ? 1 : 0
  config_rule_name = aws_config_config_rule.s3_32XX_versioning[count.index].name
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-ConfigureS3BucketVersioning"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = "arn:aws:iam::${var.prod_account_id}:role/security_config"
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }
  parameter {
    name         = "VersioningState"
    static_value = "Enabled"
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 30

}

# Tags
# -----------------------------------------------------------------------------

#
# AWS Config auto-remediation for s3 tagging 
#

# resource "aws_config_remediation_configuration" "BucketTagRemediation" {
#   count = var.check_s3_tags ? 1 : 0
#   config_rule_name = aws_config_config_rule.required_s3_tags[count.index].name
#   resource_type    = "AWS::S3::Bucket"
#   target_type      = "SSM_DOCUMENT"
#   target_id        = "AWS-SetRequiredTags"
#   target_version   = "1"

#   parameter {
#     name         = "AutomationAssumeRole"
#     static_value = "arn:aws:iam::${var.prod_account_id}:role/security_config"
#   }
#   parameter {
#     name           = "ResourceARNs"
#     resource_value = "RESOURCE_ID" # We assume this works as we can't have RESOURCE_ARN in the console
#   }

#   parameter {
#     name           = "RequiredTags"
#     resource_value = "Availability,Integrity,Confidentiality,Tracability" # We assume a csv format
#   }

#   automatic                  = true
#   maximum_automatic_attempts = 5
#   retry_attempt_seconds      = 30

# }