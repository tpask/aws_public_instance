
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
