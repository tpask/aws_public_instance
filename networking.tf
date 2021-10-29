
#create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.owner}-${var.project}"
  }
}

#create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet
  tags = {
    Name = "${var.owner}-${var.project}"
  }
}

#create gateway
resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.owner}-${var.project}"
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
    Name = "${var.owner}-${var.project}"
  }
}

#associate route to subnet
resource "aws_route_table_association" "my_vpc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.my_vpc_rt.id
}

# private subnet ***** w/ nat
resource "aws_subnet" "private_nated" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_nated_subnet

  tags = {
    Name = "${var.owner}-${var.project}-NAT-ed Subnet"
  }
}


resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public.id
}

resource "aws_route_table" "my_vpc_nated" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw.id
    }

    tags = {
        Name = "${var.owner}-${var.project}-Main RT for NAT-ed subnet"
    }
}

resource "aws_route_table_association" "my_vpc_nated" {
    subnet_id = aws_subnet.private_nated.id
    route_table_id = aws_route_table.my_vpc_nated.id
}
#see https://hands-on.cloud/terraform-managing-aws-vpc-creating-private-subnets/
