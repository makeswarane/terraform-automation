resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier            = "app-db"
  engine                = "postgres"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  vpc_security_group_ids = [var.db_sg]
  db_subnet_group_name  = aws_db_subnet_group.main.name
  skip_final_snapshot   = true
}
