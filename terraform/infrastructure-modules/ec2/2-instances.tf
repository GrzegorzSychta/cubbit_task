provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "instances" {
  for_each = var.instances

  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_ids[each.value.subnet_index]
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name

  tags = merge(
    {
      Name        = each.value.name
      Environment = var.env
    },
    each.value.tags
  )
}
