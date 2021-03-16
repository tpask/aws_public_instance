provider "aws" { region = var.region }
variable "region" { default = "us-west-2" }
variable "owner" { default = "tp" }
variable "ami" { default = "ami-0bc06212a56393ee1" }
variable "instance_type" { default = "t3.small" }
variable "project" {
  type = string
  default = "test"
}

variable "pub_key_file" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

#get my local address:
data "http" "workstation-external-ip" { url = "http://ipv4.icanhazip.com" }
locals { workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32" }
