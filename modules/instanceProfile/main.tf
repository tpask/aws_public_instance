# creates a role and attach it to your instance.
# this is optional. Rename to .tf extension if you want to define a Role for your EC2(s)
/*
var.owner, var.project, 

*/

# create role:
resource "aws_iam_role" "ec2_role" {
  name = "${var.owner}-${var.project}_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "${var.owner}-${var.project}"
  }
}

# create instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.owner}-${var.project}_profile"
  role = aws_iam_role.ec2_role.name
}

#creat at least 1 policy:
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.owner}-${var.project}-ec2_policy"
  role = aws_iam_role.ec2_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "sts:AssumeRole" ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
