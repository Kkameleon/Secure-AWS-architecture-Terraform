# A s3 bucket ready to receive logs, encrypted, which blocks all non authorized traffic
module "config_logs" {
  source  = "trussworks/logs/aws"
  version = "~> 10"

  s3_bucket_name              = var.logs_s3_name

  default_allow               = false
  allow_cloudtrail            = true
  allow_cloudwatch            = true
  allow_config                = true

  cloudtrail_logs_prefix      = "cloudtrail"
  cloudwatch_logs_prefix      = "cloudwatch"
  config_logs_prefix          = "config"

  force_destroy               = true

  cloudtrail_accounts         = [var.prod_account_id]
  config_accounts             = [var.prod_account_id]
  
  s3_log_bucket_retention     = 180

   tags = {
    "Automation"            = "Terraform"
    "Name"                  = var.logs_s3_name

    "Availability"          =  "4"
    "Integrity"             =  "4"
    "Confidentiality"       =  "4"
    "Tracability"           =  "4"
  }
}
