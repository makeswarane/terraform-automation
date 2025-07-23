# modules/network/main.tf: Network setup with dynamic multi-subnet support
# Creates VPC, subnets, IGW, routes, NAT (if enabled) or uses existing
# // cmd: Called from root; no direct command needed

# Data sources for existing network (if create_network=false)
data "aws_vpc" "existing" {
  count = !var.create_network ? 1 : 0
  id    = var.existing_vpc_id != "" ? var.existing_vpc_id : null
}

data "aws_subnet" "existing" {
  count = !var.create_network ? length(var.existing_subnet_ids) : 0
  id    = var.existing_subnet_ids[count.index]
}

# VPC creation (if create_network=true)
resource "aws_vpc" "this" {
  count             = var.create_network ? 1 : 0
  cidr_block        = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags              = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Subnets creation (dynamic multi-subnet across AZs)
resource "aws_subnet" "this" {
  count                   = var.create_network ? length(var.subnet_cidr_blocks) : 0
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.subnet_cidr_blocks[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = var.public_subnets[count.index]
  tags                    = merge(var.tags, { Name = "${var.subnet_cidr_blocks[count.index]}-${var.azs[count.index]}" })

  lifecycle {
    ignore_changes = [tags]
  }
}

# Internet Gateway for public subnets (if creating)
resource "aws_internet_gateway" "this" {
  count  = var.create_network ? 1 : 0
  vpc_id = aws_vpc.this[0].id
  tags   = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Route table for public subnets (to IGW)
resource "aws_route_table" "public" {
  count  = var.create_network ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = merge(var.tags, { Name = "public-rt" })

  lifecycle {
    ignore_changes = [route]
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = var.create_network ? length([for i in range(length(var.subnet_cidr_blocks)) : i if var.public_subnets[i]]) : 0
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# NAT Gateway for private subnets (if enabled and creating)
resource "aws_eip" "nat" {
  count = var.create_network && var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags   = var.tags
}

resource "aws_nat_gateway" "this" {
  count         = var.create_network && var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.this[0].id  # Place in first subnet (adjustable)
  tags          = var.tags

  depends_on = [aws_internet_gateway.this]
}

# Route table for private subnets (to NAT if enabled)
resource "aws_route_table" "private" {
  count  = var.create_network && var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this[0].id
  }

  tags = merge(var.tags, { Name = "private-rt" })

  lifecycle {
    ignore_changes = [route]
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = var.create_network && var.enable_nat_gateway ? length([for i in range(length(var.subnet_cidr_blocks)) : i if !var.public_subnets[i]]) : 0
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.private[0].id
}
