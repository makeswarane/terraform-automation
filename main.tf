# main.tf: Main launcher for Reusable EC2 Terraform Library
# Covers ALL AWS EC2 console options dynamically (full instance creation template)
# Supports multi-region (per instance), multi-instance launch (e.g., 10+ in one apply), PEM key gen to S3
# // cmd: terraform init - to initialize providers and modules
# // cmd: terraform validate - to check syntax
# // cmd: terraform plan - to preview changes (e.g., 10 instances across regions)
# // cmd: terraform apply - to launch all in one go (one-click)
# // cmd: terraform destroy - to clean up

# Primary provider (default region)
provider "aws" {
  alias  = "primary"
  region = var.aws_region
}

# Multi-region providers (fixed aliases based on var.regions map)
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

# // DYNAMIC VALUE: Add more provider aliases for other regions if needed (update var.regions in terraform.tfvars and add here)

# Network module (dynamic per instance's region via alias)
module "network" {
  source = "./modules/network"
  for_each = { for inst in var.instances : inst.name => inst }

  providers = {
    aws = aws[lookup(each.value, "region", var.aws_region)]
  }

  create_network = var.create_network  // cmd: Change in terraform.tfvars, type: bool, e.g., create_network = false (use existing)
  vpc_cidr_block = lookup(each.value, "vpc_cidr", var.vpc_cidr_block)  // cmd: Change in terraform.tfvars, type: string, e.g., vpc_cidr_block = "10.1.0.0/16"
  subnet_cidr_blocks = lookup(each.value, "subnet_cidrs", var.subnet_cidr_blocks)  // cmd: Change in terraform.tfvars, type: list(string), e.g., subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  azs = lookup(each.value, "availability_zones", var.azs)  // cmd: Change in terraform.tfvars, type: list(string), e.g., azs = ["us-east-1a", "us-east-1b"]
  public_subnets = lookup(each.value, "public_subnets", var.public_subnets)  // cmd: Change in terraform.tfvars, type: list(bool), e.g., public_subnets = [true, false]
  enable_nat_gateway = lookup(each.value, "nat_gateway", var.enable_nat_gateway)  // cmd: Change in terraform.tfvars, type: bool, e.g., enable_nat_gateway = true
  existing_vpc_id = var.vpc_id  // cmd: Change in terraform.tfvars, type: string, e.g., vpc_id = "vpc-12345" (if not creating)
  existing_subnet_ids = var.subnet_ids  // cmd: Change in terraform.tfvars, type: list(string), e.g., subnet_ids = ["subnet-12345"] (if not creating)
  tags = var.default_tags  // cmd: Change in terraform.tfvars, type: map(string), e.g., default_tags = { Env = "prod" }
}

# Generate PEM keys for instances where create_pem_key=true, store private in S3
resource "tls_private_key" "ec2_key" {
  for_each  = { for inst in var.instances : inst.name => inst if lookup(inst, "create_pem_key", false) }
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  for_each    = tls_private_key.ec2_key
  provider    = aws[lookup(var.instances[each.key], "region", var.aws_region)]  // Fixed: Use map lookup (each.key is the name)
  key_name    = "${each.key}-key"
  public_key  = tls_private_key.ec2_key[each.key].public_key_openssh
  tags        = var.default_tags
}

resource "aws_s3_object" "private_key" {
  for_each     = tls_private_key.ec2_key
  provider     = aws[lookup(var.instances[each.key], "region", var.aws_region)]  // Fixed: Same as above
  bucket       = var.s3_bucket_name  // cmd: Change in terraform.tfvars, type: string, e.g., s3_bucket_name = "my-bucket"
  key          = "${each.key}-private.pem"
  content      = tls_private_key.ec2_key[each.key].private_key_pem
  content_type = "text/plain"
  server_side_encryption = "AES256"
  tags         = var.default_tags
}

# EC2 instances module (dynamic multi-launch, multi-region)
module "ec2_instances" {
  source   = "./modules/ec2_instance"
  for_each = { for inst in var.instances : inst.name => inst }

  providers = {
    aws = aws[lookup(each.value, "region", var.aws_region)]
  }

  name                           = each.value.name  // cmd: Change in terraform.tfvars, type: string, e.g., name = "web-server"
  ubuntu_version                 = each.value.ubuntu_version  // cmd: Change in terraform.tfvars, type: string, e.g., ubuntu_version = "22.04"
  instance_type                  = each.value.instance_type  // cmd: Change in terraform.tfvars, type: string, e.g., instance_type = "t2.micro"
  key_name                       = lookup(each.value, "create_pem_key", false) ? aws_key_pair.ec2_key[each.key].key_name : lookup(each.value, "key_name", null)  // cmd: Change in terraform.tfvars, type: string, e.g., key_name = "my-key"
  create_key_pair                = lookup(each.value, "create_key_pair", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., create_key_pair = true
  existing_instance_id           = lookup(each.value, "existing_instance_id", null)  // cmd: Change in terraform.tfvars, type: string, e.g., existing_instance_id = "i-12345"
  ami_id                         = lookup(each.value, "ami_id", null)  // cmd: Change in terraform.tfvars, type: string, e.g., ami_id = "ami-0abcdef"
  number_of_instances            = lookup(each.value, "number_of_instances", 1)  // cmd: Change in terraform.tfvars, type: number, e.g., number_of_instances = 5 (multi-launch)
  purchasing_option              = lookup(each.value, "purchasing_option", "on_demand")  // cmd: Change in terraform.tfvars, type: string, e.g., purchasing_option = "spot"
  spot_price                     = lookup(each.value, "spot_price", null)  // cmd: Change in terraform.tfvars, type: string, e.g., spot_price = "0.01"
  volume_size                    = each.value.volume_size  // cmd: Change in terraform.tfvars, type: number, e.g., volume_size = 20
  assign_eip                     = lookup(each.value, "assign_eip", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., assign_eip = true
  user_data                      = file("${path.module}/modules/ec2_instance/${lookup(each.value, "user_data", "")}")  // cmd: Change in terraform.tfvars, type: string, e.g., user_data = "userdata-web.sh"
  iam_role                       = lookup(each.value, "iam_role", null)  // cmd: Change in terraform.tfvars, type: string, e.g., iam_role = "ec2-role"
  shutdown_behavior              = lookup(each.value, "shutdown_behavior", "stop")  // cmd: Change in terraform.tfvars, type: string, e.g., shutdown_behavior = "terminate"
  monitoring                     = lookup(each.value, "monitoring", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., monitoring = true
  elastic_gpu                    = lookup(each.value, "elastic_gpu", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., elastic_gpu = true
  security_ports                 = lookup(each.value, "security_ports", [])  // cmd: Change in terraform.tfvars, type: list(number), e.g., security_ports = [22, 80]
  public_access                  = lookup(each.value, "public_access", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., public_access = true
  termination_protection         = lookup(each.value, "termination_protection", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., termination_protection = true
  placement_group                = lookup(each.value, "placement_group", null)  // cmd: Change in terraform.tfvars, type: string, e.g., placement_group = "my-group"
  additional_security_group_ids  = lookup(each.value, "additional_security_group_ids", [])  // cmd: Change in terraform.tfvars, type: list(string), e.g., additional_security_group_ids = ["sg-123"]
  additional_ebs_volumes         = lookup(each.value, "additional_ebs_volumes", [])  // cmd: Change in terraform.tfvars, type: list(object), e.g., additional_ebs_volumes = [{device_name = "/dev/sdb", size = 50}]
  additional_network_interfaces  = lookup(each.value, "additional_network_interfaces", [])  // cmd: Change in terraform.tfvars, type: list(object), e.g., additional_network_interfaces = [{device_index = 1, private_ips = ["10.0.1.100"]}]
  cpu_credits                    = lookup(each.value, "cpu_credits", "standard")  // cmd: Change in terraform.tfvars, type: string, e.g., cpu_credits = "unlimited"
  hibernation                    = lookup(each.value, "hibernation", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., hibernation = true
  enclave_enabled                = lookup(each.value, "enclave_enabled", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., enclave_enabled = true
  tenancy                        = lookup(each.value, "tenancy", "default")  // cmd: Change in terraform.tfvars, type: string, e.g., tenancy = "dedicated"
  metadata_http_tokens           = lookup(each.value, "metadata_http_tokens", "optional")  // cmd: Change in terraform.tfvars, type: string, e.g., metadata_http_tokens = "required"
  metadata_http_endpoint         = lookup(each.value, "metadata_http_endpoint", "enabled")  // cmd: Change in terraform.tfvars, type: string, e.g., metadata_http_endpoint = "disabled"
  private_dns_enabled            = lookup(each.value, "private_dns_enabled", true)  // cmd: Change in terraform.tfvars, type: bool, e.g., private_dns_enabled = false
  ebs_optimized                  = lookup(each.value, "ebs_optimized", true)  // cmd: Change in terraform.tfvars, type: bool, e.g., ebs_optimized = false
  source_dest_check              = lookup(each.value, "source_dest_check", true)  // cmd: Change in terraform.tfvars, type: bool, e.g., source_dest_check = false
  root_volume_encrypted          = lookup(each.value, "root_volume_encrypted", false)  // cmd: Change in terraform.tfvars, type: bool, e.g., root_volume_encrypted = true
  root_delete_on_termination     = lookup(each.value, "root_delete_on_termination", true)  // cmd: Change in terraform.tfvars, type: bool, e.g., root_delete_on_termination = false
  root_iops                      = lookup(each.value, "root_iops", null)  // cmd: Change in terraform.tfvars, type: number, e.g., root_iops = 3000
  root_throughput                = lookup(each.value, "root_throughput", null)  // cmd: Change in terraform.tfvars, type: number, e.g., root_throughput = 125
  tags                           = merge(var.default_tags, { Name = each.value.name })

  vpc_id             = module.network[each.key].vpc_id
  subnet_id          = module.network[each.key].subnet_ids[0]  // First subnet; adjust for multi-subnet
  public_key_path    = var.public_key_path
  depends_on         = [module.network]  // Ensure network is ready
}
