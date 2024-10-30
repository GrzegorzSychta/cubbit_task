variable "env" {
  description = "Environment name."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be deployed."
  type        = list(string)
}

variable "key_name" {
  description = "Key pair name to use for the instances."
  type        = string
}

variable "instances" {
  description = "Map of instance configurations."
  type        = map(object({
    name          = string
    ami_id        = string
    instance_type = string
    subnet_index  = number
    tags          = optional(map(string), {})
  }))
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH into instances."
  type        = list(string)
}