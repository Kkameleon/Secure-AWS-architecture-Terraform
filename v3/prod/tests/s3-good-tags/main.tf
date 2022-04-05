resource "aws_s3_bucket" "example_s3" {
    bucket = "example_bucket"
    acl = "private"
    encrypted = true

    tags {
      Name = "GoodS3"
      env = "prod"
      Disponibility = "1"
      Integrity = "3"
      Confidentiality = "2"
      Tracability = "1"
    }
}
