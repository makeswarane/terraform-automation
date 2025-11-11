variable "aws_region" { default = "ap-south-1" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "azs" { type = list(string) }
variable "ami_id" {}
variable "instance_type" { default = "t3.micro" }
variable "key_name" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
