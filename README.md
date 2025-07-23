# Reusable EC2 Terraform Library

## Full Explanation
This Terraform library provisions AWS EC2 instances with a **full instance creation template** matching the AWS console. It supports:
- **Multi-Instance One-Click Launch**: Define 10+ instances in `terraform.tfvars` and launch all with `terraform apply`.
- **PEM Key Generation and S3 Storage**: Auto-generates SSH keys per instance (if `create_pem_key=true`), stores private keys in S3 (encrypted).
- **All AWS Console Options**: Covers every EC2 creation option (AMI, type, count, spot/on-demand, storage, network, IAM, tags, advanced settings).
- **Multi-Region Support**: Assign regions per instance (e.g., "us-east-1", "eu-west-1").
- **Dynamic Network**: Custom VPC CIDR, multi-subnets, AZs, public/private, NAT gateways.
- **CLI-First**: No UI/console needed.

## Available Options
All options are in `variables.tf` with types, defaults, and examples. Key categories:
- **Required**: `name`, `ubuntu_version`, `instance_type`, `volume_size`.
- **Basic**: `create_pem_key`, `key_name`, `number_of_instances`, `assign_eip`, `user_data`.
- **Purchase**: `purchasing_option`, `spot_price`.
- **Network**: `public_access`, `security_ports`, `additional_security_group_ids`, `additional_network_interfaces`, `vpc_cidr`, `subnet_cidrs`.
- **Storage**: `additional_ebs_volumes`, `root_volume_encrypted`, `root_iops`, `root_throughput`.
- **Advanced**: `iam_role`, `shutdown_behavior`, `monitoring`, `termination_protection`, `placement_group`, `cpu_credits`, `hibernation`, `enclave_enabled`, `tenancy`, `metadata_http_tokens`, `ebs_optimized`, etc.
- **Region**: `region` per instance for multi-region.

## Where to Change Dynamic Values
- **Primary**: `terraform.tfvars` (e.g., expand `instances` list for 10+ instances; set `s3_bucket_name`, `regions`).
- **Secondary**: CLI overrides (e.g., // cmd: terraform apply -var="s3_bucket_name=new-bucket").
- **See // cmd**: Comments in files show where/how to change with type and example.

## Step-by-Step CLI Usage
1. // cmd: terraform init - Initialize.
2. // cmd: Edit `terraform.tfvars` - Add instances (e.g., 10), S3 bucket, regions.
3. // cmd: terraform validate - Check syntax.
4. // cmd: terraform plan - Preview (see all instances, regions).
5. // cmd: terraform apply - One-click launch (all instances + keys in S3).
6. // cmd: terraform output - View IDs, IPs, S3 paths.
7. // cmd: aws s3 cp s3://your-bucket/web-server-1-private.pem . - Download PEM from S3.
8. // cmd: ssh -i web-server-1-private.pem ubuntu@public-ip - Connect to instance.
9. // cmd: terraform destroy - Cleanup.

## Diagrams and Images (ASCII as placeholder; replace with real images in repo)
### Architecture Diagram


terraform-ec2-library/
├── main.tf
├── variables.tf
├── terraform.tfvars         // DYNAMIC VALUE: Main file to change instances, regions, S3, etc.
├── outputs.tf
├── versions.tf
├── modules/
│   ├── ec2_instance/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── userdata-web.sh  // Example user data
│   │   └── userdata-gpu.sh  // Example user data
│   └── network/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md                // Full explanation, diagrams, options
