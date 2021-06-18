provider "aws" { region = var.region }

variable "region" { default = "us-west-2" }
variable "owner" { default = "tp" }
variable "ami" { default = "" }
variable "instance_type" { default = "t3.small" }
variable "other_sg_ids" {
  type = string
  default = ""
}
variable "project" {
  type = string
  default = "test"
}

variable "pub_key_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

#get my local address:
data "http" "workstation-external-ip" { url = "http://ifconfig.me" }
locals { workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32" }

# get the latest amazon-linux-2-ami 
data "aws_ami" "amz_linux" {
 most_recent = true
 owners = ["137112412989"]
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

#define userdata to execute right after boot
locals {
  instance-userdata = <<EOF
  #!/bin/bash
  yum -y update
EOF
}
