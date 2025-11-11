variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "ami_id" {}
variable "instance_type" { default = "t3.micro" }
variable "key_name" {}
