output "instance_ip_addr" { value = aws_instance.my_instance.public_ip }

#terraform output -raw instance_ip_addr
