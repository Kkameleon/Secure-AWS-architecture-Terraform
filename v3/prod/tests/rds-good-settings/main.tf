resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "myuname"
  password             = "mypasswd"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi-az             = true
  storage_encrypted    = true

  tags {
    Name = "GoodRDS"
    env = "prod"
  }
}
