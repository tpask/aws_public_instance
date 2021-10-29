# generate a random number
resource "random_integer" "number" {
  min = 10
  max = 999
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


# create role for ec2 to allow sts only
resource "aws_iam_role" "ec2_role" {
  name = "${var.owner}-${random_integer.number.result}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    purpose = var.project
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.owner}-${random_integer.number.result}-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy" "role_policy" {
  name = "${var.owner}-${random_integer.number.result}-policy"
  role = aws_iam_role.ec2_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:ListRoles",
        "sts:AssumeRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#create instance in private subnet subnet
resource "aws_instance" "private_nated" {
  # ami                         = var.ami == "" ? data.aws_ami.ubuntu.id : var.ami
  ami                         = var.ami == "" ? data.aws_ami.amz_linux.id : var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.add_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = var.other_sg_ids == "" ? [aws_security_group.allow_all.id] : [var.other_sg_ids, aws_security_group.allow_all.id]
  # root disk
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp2"
  }
  tags = {
    Name = "private - ${var.owner}-${var.project}"
  }
}

resource "aws_instance" "public" {
  # ami                         = var.ami == "" ? data.aws_ami.ubuntu.id : var.ami
  ami                         = var.ami == "" ? data.aws_ami.amz_linux.id : var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.add_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  subnet_id                   = aws_subnet.private_nated.id
  vpc_security_group_ids      = var.other_sg_ids == "" ? [aws_security_group.allow_all.id] : [var.other_sg_ids, aws_security_group.allow_all.id]
  associate_public_ip_address = true
  # root disk
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp2"
  }
  tags = {
    Name = "public - ${var.owner}-${var.project}"
  }
}

/*
# create EIP and associate it to instance
resource "aws_eip" "eip_ec2" {
  instance = aws_instance.my_instance.id
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  allocation_id = aws_eip.eip_ec2.id
  instance_id = aws_instance.my_instance.id
}
*/
