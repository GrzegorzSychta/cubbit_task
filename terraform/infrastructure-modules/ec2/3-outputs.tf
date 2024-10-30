output "instance_ids" {
  value = { for k, v in aws_instance.instances : k => v.id }
}

output "security_group_id" {
  value = aws_security_group.ec2.id
}
