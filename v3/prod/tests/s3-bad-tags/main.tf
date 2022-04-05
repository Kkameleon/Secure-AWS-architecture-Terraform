resource "aws_s3_bucket" "example_s3" {
    bucket = "example_bucket"
    acl = "public"

    tags {
      Name = "BadS3"
      env = "prod"
      Disponibility = "1"
      Integrity = "3"
    }
}
