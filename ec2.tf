provider "aws" { region = var.region }

variable "region" {
  default = "us-west-2"
}

variable "owner" {
  default = "tp"
}

variable "ami" {
  default = "ami-0bc06212a56393ee1"
}

variable "instance_type" {
  default = "t3.small"
}

variable "key_name" {
  type = string
}

#get my local address:
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

#create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.owner} - VPC"
  }
}

#create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.1.0.0/24"
  tags = {
    Name = "${var.owner}-Public Subnet"
  }
}

#create gateway
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.owner}- Internet Gateway"
  }
}

#create route table
resource "aws_route_table" "my_vpc_rt" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }
    tags = {
        Name = "${var.owner} - Public Subnet Route Table."
    }
}

#associate route to subnet
resource "aws_route_table_association" "my_vpc" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.my_vpc_rt.id
}

#create security groups
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound connections from my workstaion"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ local.workstation-external-cidr ]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.owner} - allow all to my address only"
  }
}

#create security bastian in public subnet
resource "aws_instance" "my_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids  = [ aws_security_group.allow_all.id ]
  associate_public_ip_address = true
  tags = {
    Name = "${var.owner}-aws_image_check"
  }
}
