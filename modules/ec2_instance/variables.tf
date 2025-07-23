# modules/ec2_instance/variables.tf: Input variables for EC2 module
# Matches full console template; passed from root

variable "name" {
  type = string
}

variable "ubuntu_version" {
  type = string
}

variable "ami_id" {
  type = string
  default = null
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
  default = null
}

variable "create_key_pair" {
  type = bool
  default = false
}

variable "existing_instance_id" {
  type = string
  default = null
}

variable "number_of_instances" {
  type = number
  default = 1
}

variable "purchasing_option" {
  type = string
  default = "on_demand"
}

variable "spot_price" {
  type = string
  default = null
}

variable "volume_size" {
  type = number
}

variable "assign_eip" {
  type = bool
  default = false
}

variable "user_data" {
  type = string
}

variable "iam_role" {
  type = string
  default = null
}

variable "shutdown_behavior" {
  type = string
  default = "stop"
}

variable "monitoring" {
  type = bool
  default = false
}

variable "elastic_gpu" {
  type = bool
  default = false
}

variable "security_ports" {
  type = list(number)
  default = []
}

variable "public_access" {
  type = bool
  default = false
}

variable "termination_protection" {
  type = bool
  default = false
}

variable "placement_group" {
  type = string
  default = null
}

variable "additional_security_group_ids" {
  type = list(string)
  default = []
}

variable "additional_ebs_volumes" {
  type = list(object({
    device_name = string
    size = number
    type = string
    encrypted = bool
    iops = number
    throughput = number
    delete_on_termination = bool
  }))
  default = []
}

variable "additional_network_interfaces" {
  type = list(object({
    device_index = number
    private_ips = list(string)
    security_group_ids = list(string)
  }))
  default = []
}

variable "cpu_credits" {
  type = string
  default = "standard"
}

variable "hibernation" {
  type = bool
  default = false
}

variable "enclave_enabled" {
  type = bool
  default = false
}

variable "tenancy" {
  type = string
  default = "default"
}

variable "metadata_http_tokens" {
  type = string
  default = "optional"
}

variable "metadata_http_endpoint" {
  type = string
  default = "enabled"
}

variable "private_dns_enabled" {
  type = bool
  default = true
}

variable "ebs_optimized" {
  type = bool
  default = true
}

variable "source_dest_check" {
  type = bool
  default = true
}

variable "root_volume_encrypted" {
  type = bool
  default = false
}

variable "root_delete_on_termination" {
  type = bool
  default = true
}

variable "root_iops" {
  type = number
  default = null
}

variable "root_throughput" {
  type = number
  default = null
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "public_key_path" {
  type = string
}
