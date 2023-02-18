output "instance_info" {
  value     = aws_instance.ec2[*]
  sensitive = true
}