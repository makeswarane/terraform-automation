terraform {
  backend "s3" {
    bucket         = "<YOUR-S3-BUCKET-NAME>"  # 🔹 Replace with your S3 bucket name
    key            = "terraform/state.tfstate"
    region         = "<YOUR-AWS-REGION>"      # 🔹 Same as aws_region
    dynamodb_table = "<YOUR-LOCK-TABLE>"      # 🔹 Replace with DynamoDB table name for locking
    encrypt        = true
  }
}
