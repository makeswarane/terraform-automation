# variables.tf: All input variables with types, defaults, and // cmd for changes
# Covers EVERY AWS EC2 console option in dynamic template
# // cmd: Primary change location is terraform.tfvars (e.g., instances = [...] for multi-launch)

variable "instances" {
  description = "List of EC2 configs for multi-instance launch (dynamic template for ALL console options; supports multi-launch e.g., 10+)"
  type = list(object({
    # Required (basic console options)
    name                  = string  // cmd: Change in terraform.tfvars to string e.g., "web-server" (required, console: Instance name via tag)
    ubuntu_version        = string  // cmd: Change in terraform.tfvars to string e.g., "22.04" (required, console: Quick start AMI filter)
    instance_type         = string  // cmd: Change in terraform.tfvars to string e.g., "t2.micro" (required, console: Instance type)
    volume_size           = number  // cmd: Change in terraform.tfvars to number e.g., 20 (required, console: Root device size)

    # Optional with defaults (full console coverage)
    create_pem_key        = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (generate PEM key to S3)
    key_name              = optional(string, null)  // cmd: Change in terraform.tfvars to string e.g., "my-key" (console: Key pair name)
    create_key_pair       = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (upload local key if not PEM gen)
    existing_instance_id  = optional(string, null)  // cmd: Change in terraform.tfvars to string e.g., "i-12345" (update existing, no recreate)
    ami_id                = optional(string, null)  // cmd: Change in terraform.tfvars to string e.g., "ami-0abcdef" (console: Specific AMI ID, overrides ubuntu_version)
    number_of_instances   = optional(number, 1)  // cmd: Change in terraform.tfvars to number e.g., 5 (console: Number of instances - launches multiples of this config)
    purchasing_option     = optional(string, "on_demand")  // cmd: Change in terraform.tfvars to string e.g., "spot" (console: On-demand or spot)
    spot_price            = optional(string, null)  // cmd: Change in terraform.tfvars to string e.g., "0.01" (console: Max spot price if spot)
    assign_eip            = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (console: Assign public IP or EIP)
    user_data             = optional(string, "")  // cmd: Change in terraform.tfvars to string e.g., "userdata-web.sh" (console: User data script)
    iam_role              = optional(string, null)  // cmd: Change in terraform.tfvars to string e.g., "ec2-role" (console: IAM instance profile)
    shutdown_behavior     = optional(string, "stop")  // cmd: Change in terraform.tfvars to string e.g., "terminate" (console: Shutdown behavior)
    monitoring            = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (console: Detailed monitoring)
    elastic_gpu           = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (console: Add GPU, deprecated)
    security_ports        = optional(list(number), [])  // cmd: Change in terraform.tfvars to list(number) e.g., [22, 80, 443] (console: Security group rules)
    public_access         = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (console: Auto-assign public IP)
    termination_protection = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (console: Disable API termination)
    placement_group       = optional(string, null)  // cmd: Change in terraform.tfvars to string e.g., "cluster-group" (console: Placement group)
    additional_security_group_ids = optional(list(string), [])  // cmd: Change in terraform.tfvars to list(string) e.g., ["sg-123", "sg-456"] (console: Additional security groups)
    additional_ebs_volumes = optional(list(object({
      device_name = string  // cmd: Change to string e.g., "/dev/sdb"
      size = number  // cmd: Change to number e.g., 50
      type = optional(string, "gp3")  // cmd: Change to string e.g., "io1"
      encrypted = optional(bool, false)  // cmd: Change to bool e.g., true (console: Encrypt volume)
      iops = optional(number, null)  // cmd: Change to number e.g., 3000
      throughput = optional(number, null)  // cmd: Change to number e.g., 125
      delete_on_termination = optional(bool, true)  // cmd: Change to bool e.g., false
    })), [])  // cmd: Change in terraform.tfvars to list(object) e.g., [{device_name="/dev/sdb", size=50}] (console: Add storage)
    additional_network_interfaces = optional(list(object({
      device_index = number  // cmd: Change to number e.g., 1
      private_ips = optional(list(string), [])  // cmd: Change to list(string) e.g., ["10.0.1.100"]
      security_group_ids = optional(list(string), [])  // cmd: Change to list(string) e.g., ["sg-123"]
    })), [])  // cmd: Change in terraform.tfvars to list(object) e.g., [{device_index=1, private_ips=["10.0.1.100"]}] (console: Network interfaces)
    cpu_credits           = optional(string, "standard")  // cmd: Change in terraform.tfvars to string e.g., "unlimited" (console: Credit specification for burstable)
    hibernation           = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (console: Hibernation options)
    enclave_enabled       = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (console: Nitro Enclaves)
    tenancy               = optional(string, "default")  // cmd: Change in terraform.tfvars to string e.g., "dedicated" (console: Tenancy)
    metadata_http_tokens  = optional(string, "optional")  // cmd: Change in terraform.tfvars to string e.g., "required" (console: Require IMDSv2)
    metadata_http_endpoint = optional(string, "enabled")  // cmd: Change in terraform.tfvars to string e.g., "disabled" (console: Metadata service)
    private_dns_enabled   = optional(bool, true)  // cmd: Change in terraform.tfvars to bool e.g., false (console: Private DNS hostname)
    ebs_optimized         = optional(bool, true)  // cmd: Change in terraform.tfvars to bool e.g., false (console: EBS-optimized instance)
    source_dest_check     = optional(bool, true)  // cmd: Change in terraform.tfvars to bool e.g., false (console: Source/dest. check)
    root_volume_encrypted = optional(bool, false)  // cmd: Change in terraform.tfvars to bool e.g., true (console: Root volume encryption)
    root_delete_on_termination = optional(bool, true)  // cmd: Change in terraform.tfvars to bool e.g., false (console: Delete on termination for root)
    root_iops             = optional(number, null)  // cmd: Change in terraform.tfvars to number e.g., 3000 (console: Root IOPS for io1/io2)
    root_throughput       = optional(number, null)  // cmd: Change in terraform.tfvars to number e.g., 125 (console: Root throughput for gp3)
    region                = optional(string, var.aws_region)  // cmd: Change in terraform.tfvars to string e.g., "us-west-2" (multi-region per instance)
    vpc_cidr              = optional(string, var.vpc_cidr_block)  // cmd: Change in terraform.tfvars to string e.g., "10.1.0.0/16" (per instance network)
    subnet_cidrs          = optional(list(string), var.subnet_cidr_blocks)  // cmd: Change in terraform.tfvars to list(string) e.g., ["10.1.1.0/24"]
    availability_zones    = optional(list(string), var.azs)  // cmd: Change in terraform.tfvars to list(string) e.g., ["us-east-1a"]
    public_subnets        = optional(list(bool), var.public_subnets)  // cmd: Change in terraform.tfvars to list(bool) e.g., [true, false]
    nat_gateway           = optional(bool, var.enable_nat_gateway)  // cmd: Change in terraform.tfvars to bool e.g., true (per instance network)
  }))
  default = []
  validation {
    condition     = alltrue([for inst in var.instances : contains(["stop", "terminate"], lookup(inst, "shutdown_behavior", "stop"))])
    error_message = "shutdown_behavior must be 'stop' or 'terminate'."
  }
  validation {
    condition     = alltrue([for inst in var.instances : contains(["on_demand", "spot"], lookup(inst, "purchasing_option", "on_demand"))])
    error_message = "purchasing_option must be 'on_demand' or 'spot'."
  }
}

variable "regions" {
  description = "Map of additional regions for multi-region support (keys are aliases, values are region names)"
  type        = map(string)
  default     = {
    "us-east-1" = "us-east-1",
    "us-west-2" = "us-west-2",
    "eu-west-1" = "eu-west-1"
  }  // cmd: Change in terraform.tfvars to map(string) e.g., { "ap-south-1" = "ap-south-1" } for more regions
}

variable "s3_bucket_name" {
  description = "S3 bucket for storing generated PEM keys (must exist)"
  type        = string
  default     = "your-s3-bucket-name"  // cmd: Change in terraform.tfvars to string e.g., "my-ec2-keys-bucket"
}

variable "default_tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = { Environment = "dev" }  // cmd: Change in terraform.tfvars to map(string) e.g., { Project = "ec2-lib", Owner = "team" }
}

variable "create_network" {
  description = "Create new network resources (VPC, subnets, etc.) if true; use existing if false"
  type        = bool
  default     = true  // cmd: Change in terraform.tfvars to bool e.g., false (use existing VPC/subnet)
}

variable "vpc_cidr_block" {
  description = "Default VPC CIDR block if creating (overridable per instance)"
  type        = string
  default     = "10.0.0.0/16"  // cmd: Change in terraform.tfvars to string e.g., "172.16.0.0/16"
}

variable "subnet_cidr_blocks" {
  description = "List of subnet CIDR blocks if creating (dynamic multi-subnet support across AZs)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]  // cmd: Change in terraform.tfvars to list(string) e.g., ["10.0.3.0/24"]
}

variable "azs" {
  description = "List of availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]  // cmd: Change in terraform.tfvars to list(string) e.g., ["us-east-1c"]
}

variable "public_subnets" {
  description = "List of booleans indicating if subnets are public"
  type        = list(bool)
  default     = [true, false]  // cmd: Change in terraform.tfvars to list(bool) e.g., [false, false]
}

variable "enable_nat_gateway" {
  description = "Enable NAT gateway for private subnets if creating network"
  type        = bool
  default     = false  // cmd: Change in terraform.tfvars to bool e.g., true
}

variable "vpc_id" {
  description = "Existing VPC ID if create_network=false"
  type        = string
  default     = ""  // cmd: Change in terraform.tfvars to string e.g., "vpc-12345"
}

variable "subnet_ids" {
  description = "Existing subnet IDs if create_network=false (for multi-subnet; use list)"
  type        = list(string)
  default     = []  // cmd: Change in terraform.tfvars to list(string) e.g., ["subnet-12345", "subnet-67890"]
}

variable "aws_region" {
  description = "Primary AWS region (default for instances without region specified)"
  type        = string
  default     = "us-east-1"  // cmd: Change in terraform.tfvars to string e.g., "us-west-2"
}

variable "public_key_path" {
  description = "Path to local public key file if create_key_pair=true (not used if create_pem_key=true)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"  // cmd: Change in terraform.tfvars to string e.g., "~/.ssh/custom-key.pub"
}
