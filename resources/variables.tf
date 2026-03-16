variable "region" {
  default = "us-east-1"
}

variable "lambda_role_name_prefix" {}
variable "lambda_role_path" {
}
variable "application" {
}
variable "service" {
}


variable "eventbridge_bus_name" {
}

variable "aws_env" {
  description = "AWS environment (dev, staging, production)"
}

variable "deletion_protection_enabled" {
  default = true
}

variable "point_in_time_recovery" {
  default = true
}
