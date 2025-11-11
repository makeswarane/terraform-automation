output "vpc_id" { value = module.networking.vpc_id }
output "alb_dns_name" { value = module.compute.alb_dns }
output "db_endpoint" { value = module.db.db_endpoint }
output "ec2_public_ip" {
  value       = module.compute.ec2_public_ip  # 🔹   Make sure your compute module exports public IP
  description = "Public IP of EC2"
}
