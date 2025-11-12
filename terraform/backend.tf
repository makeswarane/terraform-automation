terraform {
  backend "s3" {
    bucket         = "terraform-automation1"  # 🔹 Replace with your S3 bucket name
    key            = "terraform/state.tfstate"
    region         = "ap-south-1"      # 🔹 Same as aws_region
    dynamodb_table = "myapp-terraform-lock"      # 🔹 Replace with DynamoDB table name for locking
    encrypt        = true
  }
}
