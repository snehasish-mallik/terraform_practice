output "ec2_id_address" {
    value = aws_instance.my-server-1.public_ip
  
}