# generate a random number
resource "random_integer" "number" {
  min = 10
  max = 99
}

#add pubkey to AWS
resource "aws_key_pair" "add_key" {
  key_name   = "${var.project}-${random_integer.number.result}"
  public_key = file(var.pub_key_file)
}


#create security groups
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound connections from my workstaion"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.workstation-external-cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.owner} - allow all to my address only"
  }
}

#create security bastian in public subnet
resource "aws_instance" "my_instance" {
  ami                         = var.ami == "" ? data.aws_ami.ubuntu.id : var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.add_key.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = var.other_sg_ids == "" ? [aws_security_group.allow_all.id] : [var.other_sg_ids, aws_security_group.allow_all.id]
  associate_public_ip_address = true
#  user_data                   = data.template_file.user_data.rendered
  tags = {
    Name = "${var.owner}-${var.project}"
  }
}
