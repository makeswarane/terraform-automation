# outputs.tf: CLI outputs after apply for instance details and S3 key paths
# // cmd: terraform output - to view results (e.g., instance IDs, IPs, S3 paths)

output "instance_ids" {
  description = "Map of instance names to their IDs"
  value       = { for name, inst in module.ec2_instances : name => inst.instance_ids }
}

output "public_ips" {
  description = "Map of instance names to public IPs (or EIP if assigned)"
  value       = { for name, inst in module.ec2_instances : name => inst.public_ips }
}

output "private_ips" {
  description = "Map of instance names to private IPs"
  value       = { for name, inst in module.ec2_instances : name => inst.private_ips }
}

output "public_dns" {
  description = "Map of instance names to public DNS names"
  value       = { for name, inst in module.ec2_instances : name => inst.public_dns }
}

output "vpc_ids" {
  description = "Map of instance names to their VPC IDs (created or existing)"
  value       = { for name, net in module.network : name => net.vpc_id }
}

output "subnet_ids" {
  description = "Map of instance names to their subnet IDs (list for multi-subnet)"
  value       = { for name, net in module.network : name => net.subnet_ids }
}

output "pem_keys_in_s3" {
  description = "Map of instance names to S3 paths for generated PEM keys"
  value       = { for k, v in aws_s3_object.private_key : k => "s3://${var.s3_bucket_name}/${v.key}" }
}
