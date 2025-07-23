# versions.tf: Terraform providers and version constraints
# // cmd: terraform init - to download required providers

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"  // For PEM key generation
    }
  }
  required_version = ">= 1.0.0"
}
