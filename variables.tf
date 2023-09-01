variable "app_name" {
  description = "Name for the application (used in naming resources)"
  default     = "my_app"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "ecs_cluster_name" {
	description = "ecs cluster name"
}

variable "vpc_name" {
	description = "name of the vpc"
}

variable "security_group_name" {
	description = "Name of the security group"
}

