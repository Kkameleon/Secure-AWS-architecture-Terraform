##############################################
############### EC2  #########################
##############################################


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "EC2"
    env = "prod"
  }
  vpc_security_group_ids = ["${aws_security_group.example_sg.id}"]
}






###########################################
############# Network #####################
###########################################

resource "aws_vpc" "example_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default"

    tags = {
      Name = "VPC"
      env = "prod"
    }
}

resource "aws_subnet" "example_subnet" {
    vpc_id = "${aws_vpc.prod-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-3a"

    tags = {
      Name = "Subnet"
      env = "prod"
      exposition = "public"
    }
}

resource "aws_internet_gateway" "example_igw" {
    vpc_id = "${aws_vpc.example_vpc.id}"
    tags = {
      Name = "IGW"
      env = "prod"
    }
}


resource "aws_route_table" "example_route_table" {
    vpc_id = "${aws_vpc.example_vpc.id}"

    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.example_igw.id}"
    }

    tags {
      Name = "RT"
      env = "prod"
    }
}


resource "aws_route_table_association" "example_rta"{
    subnet_id = "${aws_subnet.example_subnet.id}"
    route_table_id = "${aws_route_table.example_route_table.id}"

    tags {
      Name = "RTA"
      env = "prod"
    }
}


resource "aws_security_group" "example_sg" {
    vpc_id = "${aws_vpc.example_vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # Should fail because of CN3
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
      Name = "SG"
      env = "prod"
    }
}
