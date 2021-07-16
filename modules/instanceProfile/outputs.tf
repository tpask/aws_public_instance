# outputs 
output "instance_profile_name" {
  description = "instance profile name of profile created"
  value       = aws_iam_instance_profile.ec2_profile.name
}
