#Run with $terraform apply -var-file="varDB.tfvars" -auto-approve

provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-3"
}





#############################
# COLLABORATIVE BACKEND BEGINNING
#############################
terraform {
 backend "s3" {
   bucket = "terraform-wavegame-rs" 
   key    = "terraform.tfstate" 
   region = "eu-west-3" 


   skip_credentials_validation = true
 }
}
#############################
# COLLABORATIVE BACKEND END
#############################








#############################
# DATABASE BEGINNING
#############################
resource "aws_db_subnet_group" "default-db-sng" {
  name       = "main"
  subnet_ids = [for k,v in aws_subnet.data : v.id]
  tags = {
    Name = "db-sng-1"
  }
}


resource "aws_db_instance" "default" {
  vpc_security_group_ids = [aws_security_group.db.id]
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.small"
  name                   = jsondecode(aws_secretsmanager_secret_version.best_secret_manager.secret_string)["name"]
  username               = jsondecode(aws_secretsmanager_secret_version.best_secret_manager.secret_string)["username"]
  password               = jsondecode(aws_secretsmanager_secret_version.best_secret_manager.secret_string)["password"]
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  kms_key_id             = aws_kms_key.key_db.arn # We need to have a db size at least small to encrypt data at rest
  storage_encrypted      = true
  db_subnet_group_name   = "main"
}

#############################
# DATABASE END
#############################









#############################
# VARIABLES DECLARATION BEGINNING
#############################

data "aws_availability_zones" "all" {}

variable "basename" {
  default = "NoFlawsOnlyFlag"
}



variable "aws_region" {
  default = "eu-west-3"
}

variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "public_subnets_cidr" {
  type = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "compute_subnets_cidr" {
  type = list(string)
  default = ["10.20.10.0/24", "10.20.11.0/24"]
}

variable "data_subnets_cidr" {
  type = list(string)
  default = ["10.20.30.0/24", "10.20.31.0/24"]
}

variable "webservers_ami" {
  default = "ami-053418e626d0549fc"
}

variable "instance_type" {
  default = "t2.micro"
}

#############################
# VARIABLES DECLARATION END
#############################







#############################
# VPC DECLARATION BEGINNING
#############################
resource "aws_vpc" "terra_vpc" {
  cidr_block       = var.vpc_cidr
  tags =  {
    Name = "TerraVPC"
  }
}

#############################
# VPC DECLARATION END
#############################








#############################
# SUBNETS DECLARATION BEGINNING
#############################

# Public subnets.
# One per availability zone is required.
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.public_subnets_cidr,count.index)
  availability_zone = sort(data.aws_availability_zones.all.names)[count.index]
  map_public_ip_on_launch  = "true"
  tags = {
    Name = "Public-Subnet-${count.index+1}"
  }
}

# Private subnets.
# One for each EC2 server
resource "aws_subnet" "compute" {
  count = length(var.compute_subnets_cidr)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.compute_subnets_cidr,count.index)
  availability_zone = sort(data.aws_availability_zones.all.names)[count.index]
  map_public_ip_on_launch  = "false"
  tags = {
    Name = "Compute-Subnet-${count.index+1}"
  }
}

# Private subnets.
# Only subnet of the database subnets group 
resource "aws_subnet" "data" {
  count = length(var.data_subnets_cidr)
  vpc_id = aws_vpc.terra_vpc.id
  cidr_block = element(var.data_subnets_cidr,count.index)
  availability_zone = sort(data.aws_availability_zones.all.names)[count.index]
  tags = {
    Name = "Data-Subnet-${count.index+1}"
  }
}

#############################
# SUBNETS DECLARATION END
#############################












#############################
# NAT AND GATEWAYS BEGINNING
#############################


# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "main"
  }
}

#NAT TRY
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.terra_igw]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = [for k, v in aws_subnet.public : v.id][0]
  depends_on    = [aws_internet_gateway.terra_igw]

  tags = {
    Name        = "NAT-gateway"
  
  }
}

#############################
# NAT AND GATEWAYS END
#############################
#############################
# ROUTE TABLES BEGINNING
#############################


# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "privateRouteTable"
  }
}


# Route table association with public subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}

# Route table association with compute subnets
resource "aws_route_table_association" "private" {
  count = length(var.compute_subnets_cidr)
  subnet_id      = element(aws_subnet.compute.*.id,count.index)
  route_table_id = aws_route_table.private_rt.id
}

#############################
# ROUTE TABLES END
#############################










#############################
# SECURITY GROUPS BEGINNING
#############################

resource "aws_security_group" "elb" {
  name        = "elb_allow_http"
  description = "Allow https inbound traffic from all sources"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "webservers" {
  name        = "ws_allow_http"
  description = "Allow http inbound traffic from ELB"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.public_subnets_cidr
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "db" {
  name        = "allow_mysql"
  description = "Allow mysql inbound traffic"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    # Only allow inbound traffic from EC2 instances.
    cidr_blocks = var.compute_subnets_cidr
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#############################
# SECURITY GROUPS END
#############################













#############################
# ELB BEGINNING
#############################

# Create a new load balancer
resource "aws_elb" "terra-elb" {
  name               = "terra-elb"
  subnets         = [for k, v in aws_subnet.public : v.id]
  security_groups = [aws_security_group.elb.id]
  
  # listener {
  #   instance_port     = 80
  #   instance_protocol = "http"
  #   lb_port           = 80
  #   lb_protocol       = "http"
  # }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
    ssl_certificate_id = aws_iam_server_certificate.my-server-cert-v.arn

    # The official terraform documentation specify : 
    # ssl_certificate_id - (Optional) The ARN of an SSL certificate you have uploaded to AWS IAM. Note ECDSA-specific restrictions below. Only valid when lb_protocol is either HTTPS or SSL
    # It's important to note that only IAM certificate are allowed
    #See our section on SSL certification below to know what happened here
  }


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "terraform-elb"
  }
}

output "elb-dns-name" {
  value = aws_elb.terra-elb.dns_name
}

#############################
# ELB END
#############################















#############################
# AUTO SCALING CONFIG BEGINNING
#############################

# LAUNCH CONFIG
resource "aws_launch_configuration" "best_launcher" {
  image_id              = "ami-053418e626d0549fc"
  instance_type         = var.instance_type
  security_groups       = [aws_security_group.webservers.id]
  iam_instance_profile  = aws_iam_instance_profile.profileAttachedToEC2.name
  user_data             = file("install_httpd.sh")
  root_block_device {
    encrypted             =  true
    volume_size           =  10
  }
  # ebs_block_device {
  #   device_name           = "/dev/sda1"
  #   encrypted             =  true
  # }
  
  
  lifecycle {
    create_before_destroy = true  
  }
}

# SCALABILITY
resource "aws_autoscaling_group" "best_autoscaling_group" {
  launch_configuration = aws_launch_configuration.best_launcher.id

  min_size = 2
  max_size = 10
  
  vpc_zone_identifier         = [for k, v in aws_subnet.compute : v.id]
  load_balancers    = [aws_elb.terra-elb.name]
  health_check_type = "ELB"
  health_check_grace_period = 300
}

#############################
# AUTO SCALING CONFIG END
#############################










#####################################-----------------------V2-------------------------###############################



#############################
# SSL CERTIFICATION  BEGINNING
#############################

#Cette section repose sur la résolution des problèmes suivants : 
#  - On a pas de dns, puisque le wordpress n'est pas déployé sur les serveurs
#  - On a pas les droits suffisant sur la console pour gérer les certificats IAM, en particulier, on ne peut ni les créer ni les lister

# Voici la démarche utilisé pour palier à ce problème :
#     - Création d'un certificat avec openssl pour *.amazonaws.com 
#     - Rajout du certificat dans les autorités de confiance du navigateur (pas obligatoire)

#Etonnament, la création de certificat via terraform ou en ligne de commande fonctionne alors que nos droits sont restreints sur la console (faille d'AWS ?), on ne peut toutefois pas les détruire
#Comme on ne peut pas détruire les ressources, on en crée de nouvelles pour avoir des instances fraiches d'où le v
resource "aws_iam_server_certificate" "my-server-cert-v" {
  name             = "my-server-cert-v"
  certificate_body = file("mycert.pem")
  private_key      = file("mykey.pem")
}

# Pour tester le comportement du certificat en premier avant de le faire sur terraform voici la démarche :
#       - Upload le certificat sur IAM via "$ aws iam upload-server-certificate --server-certificate-name my-server-cert --certificate-body file://mycert.pem --private-key file://mykey.pem"
#               - Comme on a pas les droits, normalement cette commande ne devrait pas fonctionner, or elle s'execute et 24h plus tard, on obtient un certificat et bien qu'il ne soit pas visible dans la console IAM, il est visible quand on essaie de l'ajouter à un listener
#       - Ajouter à la main le listener depuis la console (on ne peut pas le faire depuis terraform car on n'a pas l'arn)
#               - En effet la commande aws iam get-server-certificate --server-certificate-name my-server-cert ne nous donne pas les informations que l'on veut
#               - On remarque tout de même qu'elle renvoie "Unknown output type: eu-west-3" signe qu'elle connait le certificat et qu'elle n'a pas les droits au lieu de "The Server Certificate with name randomName123165 cannot be found." lorsque on demande les infos d'un certificat qui n'existe pas


# Voici le code que l'on pourrait utiliser si avait un dns valide
# On poserai un alias sur le load balancer en plus
# Remarquons que ce n'est pas un certificat IAM mais cela semble toléré par la console car il nous propose d'importer le certificat depuis différentes sources


# resource "aws_acm_certificate" "certificate_elb" {
#   domain_name       = "our_dns_name"
#   validation_method = "DNS"
# }


# data "aws_route53_zone" "external" {
#   name = "our_dns_name"
# }
# resource "aws_route53_record" "validation" {
#   name    = aws_acm_certificate.certificate_elb.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.certificate_elb.domain_validation_options.0.resource_record_type
#   zone_id = data.aws_route53_zone.external.zone_id
#   records = [aws_acm_certificate.certificate_elb.domain_validation_options.0.resource_record_value]
#   ttl     = "60"
# }
# #Certificate produced by aws_acm_certificate will be invalid very fast whereas this output is valid
# resource "aws_acm_certificate_validation" "default" {
#   certificate_arn = aws_acm_certificate.certificate_elb.arn
#   validation_record_fqdns = [aws_route53_record.validation.fqdn]
# }

# #############################
# # SSL CERTIFICATION  END
# #############################













#############################
# KMS BEGINNING
#############################

resource "aws_kms_key" "key_db" {
  description             = "This key is used to encrypt db content"
  deletion_window_in_days = 10
}

resource "aws_kms_key" "key_bucket" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_kms_key" "key_secret_manager" {
  description             = "This key is used to encrypt secret manager content"
  deletion_window_in_days = 10
}
resource "aws_kms_key" "key_ec2_volume" {
  description             = "This key is used to encrypt ec2 volumes"
  deletion_window_in_days = 10
}


#############################
# KMS END
#############################








  

#############################
# SECRET MANAGER BEGINNING
#############################

# Secrets of secret manager can't be deleted immediatly, to get a fresh instance, we need to create another one, that's why there is vv

resource "aws_secretsmanager_secret" "best_secret_vvv" {
  name = "best_secret_manager_vvv"
  kms_key_id = aws_kms_key.key_secret_manager.arn
}


# db_credentials are in a joined file for the challenge but in real situation : 
# the administrator should give the value when prompted by the shell so it's not stored anywhere and well protected by the secret manager
variable "db_credentials" {}



resource "aws_secretsmanager_secret_version" "best_secret_manager" {
  secret_id     = aws_secretsmanager_secret.best_secret_vvv.id
  secret_string = jsonencode(var.db_credentials)
}


#############################
# SECRET MANAGER END
#############################











#############################
# S3 BUCKET BEGINNING
#############################

#We want here to allow ec2 instances to use an IAM role
resource "aws_iam_role" "ec2_iam_role" {
  name = "ec2_iam_role"

  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json

}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


# The profile IAM with the expected role
resource "aws_iam_instance_profile" "profileAttachedToEC2" {
  name = "profileAttachedToEC2"
  role = aws_iam_role.ec2_iam_role.name
}

# The role policy, full access on the s3 bucket
resource "aws_iam_role_policy" "rolePolicyAttachedToRoleProfile" {
  name = "rolePolicyAttachedToRoleProfile"
  role = aws_iam_role.ec2_iam_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# The vpc endpoint for the s3 bucket
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.terra_vpc.id
  service_name = "com.amazonaws.eu-west-3.s3"
  vpc_endpoint_type = "Gateway"
  auto_accept = true
  route_table_ids = [aws_route_table.public_rt.id, aws_route_table.private_rt.id]
}


# The bucket encrypted
# /!\ YOU NEED TO USE --sse aws:kms WHEN SENDING FILES TO AN ENCRYPT BUCKET !!!!
resource "aws_s3_bucket" "best_bucket" {
  bucket = "bucket-logs-no-flaws-only-flag"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.key_bucket.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

#############################
# S3 BUCKET END
#############################














#############################
# CLOUDTRAIL BEGINNING
#############################


# On a pas les droits sur cloudtrail non plus, on peut créer des logs_groups et des logs_stream mais pas les détruire 


# resource "aws_cloudwatch_log_group" "cloudtrail_logging" {
#  name              = "CloudTrail/MonAppLogGroup"
#  retention_in_days = 1
# }

# resource "aws_cloudtrail" "trail" {
#  name = "${var.basename}-cloudtrail"
#  s3_bucket_name = aws_s3_bucket.best_bucket.id
#  s3_key_prefix = var.basename
#  include_global_service_events = true
#  enable_logging = true
#  is_multi_region_trail = true
#  kms_key_id = aws_kms_key.key_bucket.arn
#  enable_log_file_validation = true
#  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_to_cloudwatch_role.arn
#  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail_logging.arn
#  event_selector {
#    read_write_type           = "All"
#    include_management_events = true

#    data_resource {
#      type   = "AWS::S3::Object"
#      values = ["arn:aws:s3:::"]
#    }
#  }
#  depends_on = [aws_s3_bucket_policy.CloudTrailS3Bucket]

# }

# resource "aws_s3_bucket_policy" "CloudTrailS3Bucket" {
#   bucket = aws_s3_bucket.best_bucket.id
#   depends_on = [aws_s3_bucket.best_bucket]
#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [{
#             "Sid": "AWSCloudTrailAclCheck",
#             "Effect": "Allow",
#             "Principal": { "Service": "cloudtrail.amazonaws.com" },
#             "Action": "s3:GetBucketAcl",
#             "Resource": "arn:aws:s3:::best_bucket"
#         },
#         {
#             "Sid": "AWSCloudTrailWrite",
#             "Effect": "Allow",
#             "Principal": { "Service": "cloudtrail.amazonaws.com" },
#             "Action": "s3:PutObject",
#             "Resource": ["arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_logging.name}:log-stream:${var.account_id}_CloudTrail_${var.aws_region}*"]
            
#         }]

# }
# POLICY
# }
# #"Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } }
# resource "aws_iam_role" "cloudtrail_to_cloudwatch_role" {
#  name  = "cloudtrail_to_cloudwatch_role"
#  assume_role_policy = data.aws_iam_policy_document.cloudtrail_to_cloudwatch_assume_role_policy.json
# }

# // IAM Policy Document: Allow CloudTrail to AssumeRole
# data "aws_iam_policy_document" "cloudtrail_to_cloudwatch_assume_role_policy" {

#  statement {
#    sid     = "AWSCloudTrailAssumeRole"
#    effect  = "Allow"
#    actions = ["sts:AssumeRole"]

#    principals {
#      type        = "Service"
#      identifiers = ["cloudtrail.amazonaws.com"]
#    }
#  }
# }

# data "aws_iam_policy_document" "cloudtrail_to_cloudwatch_create_logs" {
#  statement {
#    sid       = "AWSCloudTrailCreateLogStream"
#    effect    = "Allow"
#    #actions   = ["logs:CreateLogStream"]
#    actions   = ["s3:CreateLogStream"]
#   # var.aws_region: region en cours
#   # var.account_id   : compte aws
#   resources = ["arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_logging.name}:log-stream:${var.account_id}_CloudTrail_${var.aws_region}*"]
#     #resources = [aws_cloudwatch_log_group.cloudtrail_logging.arn]
#  }
#   statement {
#    sid       = "AWSCloudTrailPutObjects"
#    effect    = "Allow"
#    #actions   = ["logs:CreateLogStream"]
#    actions   = ["s3:PutObject"]
#   # var.aws_region: region en cours
#   # var.account_id   : compte aws
#   resources = ["arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_logging.name}:log-stream:${var.account_id}_CloudTrail_${var.aws_region}*"]
#   #resources = [aws_cloudwatch_log_group.cloudtrail_logging.arn]
#  }

#  statement {
#    sid       = "AWSCloudTrailPutLogEvents"
#    effect    = "Allow"
#    actions   = ["logs:PutLogEvents"]
#    resources = ["arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_logging.name}:log-stream:${var.account_id}_CloudTrail_${var.aws_region}*"]
#    #resources = [aws_cloudwatch_log_group.cloudtrail_logging.arn]
 
#  }
# }

# resource "aws_iam_role_policy" "cloudtrail_to_cloudwatch_create_logs" {
#  name   = "CloudTrailToCloudWatchCreateLogs"
#  role   = aws_iam_role.cloudtrail_to_cloudwatch_role.id
#  policy = data.aws_iam_policy_document.cloudtrail_to_cloudwatch_create_logs.json
# }



#############################
# CLOUDTRAIL END
#############################

