# modules/network/outputs.tf: Outputs for network details

output "vpc_id" {
  value = var.create_network ? aws_vpc.this[0].id : (var.existing_vpc_id != "" ? data.aws_vpc.existing[0].id : "")
}

output "subnet_ids" {
  value = var.create_network ? aws_subnet.this[*].id : (length(var.existing_subnet_ids) > 0 ? data.aws_subnet.existing[*].id : [])
}
