provider "aws" { region = "us-west-2" }

variable "vpc_cidr" { default = "10.1.0.0/16" }
variable "public_subnet" { default = "10.1.1.0/24" }
variable "private_nated_subnet" { default = "10.1.2.0/24" }
variable "region" { default = "us-west-2" }
variable "owner" { default = "tp" }
variable "ami" { default = "" }
variable "instance_type" { default = "t3.micro" }
variable "volume_size" { default = "25" }
variable "other_sg_ids" {
  type    = string
  default = ""
}

variable "project" {
  type    = string
  default = "test"
}

variable "pubkey_file" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

#get my local address:
data "http" "my_ip" { url = "http://checkip.amazonaws.com/"}
data "http" "workstation-external-ip" { url = "http://ifconfig.me" }

# get the latest amazon-linux-2-ami
data "aws_ami" "amz_linux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

#ubuntu ami
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
  owners = ["099720109477"]
}

#output "test" {
#  value = data.aws_ami.ubuntu
#}

#define userdata to execute right after boot
locals {
  instance-userdata = <<EOF
  #!/bin/bash
  yum -y update
EOF
}
