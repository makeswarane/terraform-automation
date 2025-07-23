# modules/ec2_instance/outputs.tf: Outputs for instance details

output "instance_ids" {
  value = var.existing_instance_id != null ? [var.existing_instance_id] : aws_instance.this[*].id
}

output "public_ips" {
  value = var.assign_eip ? aws_eip.this[*].public_ip : (var.existing_instance_id != null ? [data.aws_instance.existing[0].public_ip] : aws_instance.this[*].public_ip)
}

output "private_ips" {
  value = var.existing_instance_id != null ? [data.aws_instance.existing[0].private_ip] : aws_instance.this[*].private_ip
}

output "public_dns" {
  value = var.existing_instance_id != null ? [data.aws_instance.existing[0].public_dns] : aws_instance.this[*].public_dns
}
