

output "public_ip" { value = aws_instance.my_instance[*].public_ip }

#terraform output -raw public_ip
# to ssh to instance, ssh user@$(tf output -raw public_ip)
