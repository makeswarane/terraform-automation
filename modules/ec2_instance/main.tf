# modules/ec2_instance/main.tf: Core EC2 logic with full AWS console template
# Handles individual instance creation (multi via for_each from root)
# // cmd: This module is called dynamically from root; no direct command needed

# Data source for latest Ubuntu AMI (if ami_id not provided)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical owner for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-${var.ubuntu_version}-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for existing key pair (if key_name provided and not creating)
data "aws_key_pair" "existing" {
  count      = var.key_name != null && !var.create_key_pair ? 1 : 0
  key_name   = var.key_name
}

# Resource to create/upload key pair from local file (if create_key_pair=true)
resource "aws_key_pair" "this" {
  count      = var.key_name != null && var.create_key_pair ? 1 : 0
  key_name   = var.key_name
  public_key = file(var.public_key_path)
  tags       = var.tags

  lifecycle {
    ignore_changes = [public_key]
  }
}

# Security group for instance if public_access=true (dynamic ports)
resource "aws_security_group" "this" {
  count       = var.public_access ? 1 : 0
  name        = "${var.name}-sg"
  description = "Security Group for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.security_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # Open to world (adjustable)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

# IAM instance profile for attaching role to instance
resource "aws_iam_instance_profile" "this" {
  count = var.iam_role != null ? 1 : 0
  name  = "${var.name}-profile"
  role  = var.iam_role

  lifecycle {
    ignore_changes = [role]
  }
}

# Placement group for clustering (if specified)
resource "aws_placement_group" "this" {
  count    = var.placement_group != null ? 1 : 0
  name     = var.placement_group
  strategy = "cluster"  # Default strategy (adjustable)
  tags     = var.tags
}

# Main EC2 instance resource (full console template)
resource "aws_instance" "this" {
  count = var.existing_instance_id == null ? var.number_of_instances : 0  # Dynamic count for multiple identical instances

  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu.id  # Custom AMI or Ubuntu
  instance_type               = var.instance_type
  key_name                    = var.key_name != null ? (var.create_key_pair ? aws_key_pair.this[0].key_name : data.aws_key_pair.existing[0].key_name) : null
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = concat(var.public_access ? [aws_security_group.this[0].id] : [], var.additional_security_group_ids)
  iam_instance_profile        = var.iam_role != null ? aws_iam_instance_profile.this[0].name : null
  user_data                   = var.user_data
  monitoring                  = var.monitoring
  disable_api_termination     = var.termination_protection
  placement_group             = var.placement_group != null ? aws_placement_group.this[0].name : null
  instance_initiated_shutdown_behavior = var.shutdown_behavior
  associate_public_ip_address = var.public_access
  ebs_optimized               = var.ebs_optimized
  hibernation                 = var.hibernation
  tenancy                     = var.tenancy
  source_dest_check           = var.source_dest_check

  # Spot instance settings if purchasing_option=spot
  dynamic "instance_market_options" {
    for_each = var.purchasing_option == "spot" ? [1] : []
    content {
      market_type = "spot"
      spot_options {
        max_price = var.purchasing_option == "spot" ? var.spot_price : null
      }
    }
  }

  credit_specification {
    cpu_credits = var.cpu_credits  # For burstable instances
  }

  enclave_options {
    enabled = var.enclave_enabled  # Nitro Enclaves
  }

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint  # IMDS enable/disable
    http_tokens                 = var.metadata_http_tokens    # IMDSv2 requirement
    http_put_response_hop_limit = 1
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record    = var.private_dns_enabled
    enable_resource_name_dns_aaaa_record = false
    hostname_type                       = "ip-name"
  }

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"  # Default type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = var.root_delete_on_termination
    iops                  = var.root_iops != null ? var.root_iops : 0
    throughput            = var.root_throughput != null ? var.root_throughput : 0
    tags                  = var.tags
  }

  # Dynamic additional EBS volumes (n-number from console)
  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.type
      encrypted             = ebs_block_device.value.encrypted
      iops                  = ebs_block_device.value.iops != null ? ebs_block_device.value.iops : 0
      throughput            = ebs_block_device.value.throughput != null ? ebs_block_device.value.throughput : 0
      delete_on_termination = ebs_block_device.value.delete_on_termination
      tags                  = var.tags
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      ami,           # Ignore AMI updates to prevent recreation
      tags,          # Ignore tag changes if managed externally
      user_data,     # Ignore user data changes if updated often
    ]
    prevent_destroy = var.termination_protection  # Protect from accidental destroy
  }
}

# Data source for existing instance (if updating, not creating)
data "aws_instance" "existing" {
  count       = var.existing_instance_id != null ? 1 : 0
  instance_id = var.existing_instance_id
}

# Elastic IP association (if assign_eip=true)
resource "aws_eip" "this" {
  count    = var.assign_eip ? var.number_of_instances : 0
  instance = var.existing_instance_id != null ? var.existing_instance_id : aws_instance.this[count.index].id
  domain   = "vpc"  # Required for VPC
  tags     = var.tags
}

# Elastic GPU (deprecated, for legacy support)
resource "aws_elastic_gpu" "this" {
  count = var.elastic_gpu ? var.number_of_instances : 0
  elastic_gpu_specifications {
    type = "eg1.medium"  # Default type
  }
  tags = var.tags
}

resource "aws_elastic_gpu_association" "this" {
  count           = var.elastic_gpu ? var.number_of_instances : 0
  elastic_gpu_id  = aws_elastic_gpu.this[count.index].id
  instance_id     = var.existing_instance_id != null ? var.existing_instance_id : aws_instance.this[count.index].id
}
