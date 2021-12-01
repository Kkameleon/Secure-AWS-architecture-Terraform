# A s3 bucket ready to receive logs, encrypted, which blocks all non authorized traffic
module "config_logs" {
  source  = "trussworks/logs/aws"
  version = "~> 10"

  s3_bucket_name              = var.logs_s3_name

  allow_config                = true
  allow_alb                   = true
  allow_cloudtrail            = true
  allow_cloudwatch            = true

  cloudtrail_logs_prefix      = "cloudtrail"
  config_logs_prefix          = "config"
  cloudwatch_logs_prefix      = "cloudwatch"
  alb_logs_prefixes           = ["alb"]
  force_destroy               = true

  alb_account                 = var.app_account_id
  cloudtrail_accounts         = [var.app_account_id]
  config_accounts             = [var.app_account_id]

   tags = {
    "Automation"            = "Terraform"
    "Name"                  = var.logs_s3_name
  }
}