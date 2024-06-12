# generate a random number
resource "random_integer" "number" {
  min = 10
  max = 999
}

#add pubkey to AWS
resource "aws_key_pair" "add_key" {
  key_name   = "${var.project}-${random_integer.number.result}"
  public_key = file(var.pubkey_file)
}

#create security groups
resource "aws_security_group" "allow_all" {
  name        = "${var.project}-${random_integer.number.result}"
  description = "Allow all inbound connections from my workstaion"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Owner = "${var.owner} - allow all to my address only",
    Name = "${var.owner}-${var.project}-${random_integer.number.result}"
  }
}

resource "aws_instance" "public" {
  # ami                         = var.ami == "" ? data.aws_ami.ubuntu.id : var.ami
  ami                         = var.ami == "" ? data.aws_ami.amz_linux.id : var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.add_key.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = var.other_sg_ids == "" ? [aws_security_group.allow_all.id] : [var.other_sg_ids, aws_security_group.allow_all.id]
  associate_public_ip_address = true
  metadata_options { http_tokens = "required" }
  # root disk
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp2"
  }
  tags = {
    Name = "public - ${var.owner}-${var.project}"
  }
}


