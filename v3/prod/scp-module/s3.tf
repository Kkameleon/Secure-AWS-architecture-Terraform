# Deployment of the objects in the SCP Bucket to create SCP
# Add a delay to save the lambda RAM
data "aws_s3_bucket" "scp" {
  bucket = var.scp_bucket_id
}

resource "aws_s3_bucket_object" "scp_1" {
  bucket = data.aws_s3_bucket.scp.id
  key    = "scp-1.json"
  source = "${path.module}/scp-policies/scp-1.json"
  etag = filemd5("${path.module}/scp-policies/scp-1.json")
}

resource "time_sleep" "scp_1" {
  create_duration = "5s"
  destroy_duration = "5s"

  depends_on = [aws_s3_bucket_object.scp_1]
}

resource "aws_s3_bucket_object" "scp_2" {
  bucket = data.aws_s3_bucket.scp.id
  key    = "scp-2.json"
  source = "${path.module}/scp-policies/scp-2.json"
  etag = filemd5("${path.module}/scp-policies/scp-2.json")

  depends_on = [time_sleep.scp_1]
}

resource "time_sleep" "scp_2" {
  create_duration = "5s"
  destroy_duration = "5s"

  depends_on = [aws_s3_bucket_object.scp_2]
}

resource "aws_s3_bucket_object" "scp_3" {
  bucket = data.aws_s3_bucket.scp.id
  key    = "scp-3.json"
  source = "${path.module}/scp-policies/scp-3.json"
  etag = filemd5("${path.module}/scp-policies/scp-3.json")

  depends_on = [time_sleep.scp_2]
}