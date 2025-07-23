# modules/network/variables.tf: Input variables for network module

variable "create_network" {
  description = "Create new network if true; use existing if false"
  type        = bool
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block if creating"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "List of subnet CIDR blocks if creating"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of booleans indicating if subnets are public"
  type        = list(bool)
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway for private subnets"
  type        = bool
}

variable "tags" {
  description = "Tags for network resources"
  type        = map(string)
}

variable "existing_vpc_id" {
  description = "Existing VPC ID if not creating (fallback)"
  type        = string
  default     = ""
}

variable "existing_subnet_ids" {
  description = "Existing subnet IDs if not creating (fallback for multi-subnet)"
  type        = list(string)
  default     = []
}
