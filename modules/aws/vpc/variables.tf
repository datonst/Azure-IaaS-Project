variable "prefix" {
  description = "Prefix for the resources"
  type        = string
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "aws_subnet_prefixes" {
  description = "AWS Test VM Subnet Prefix"
  type        = list(string)
}
