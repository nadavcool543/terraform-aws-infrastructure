# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "terraform-drills-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  # Allow MySQL access from EC2 security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  tags = {
    Name        = "RDS Security Group"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier        = "terraform-drills-rds"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  
  db_name  = "terraform_drills"
  username = "admin"
  password = "password123!"  # In production, use secrets management!

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot = true

  tags = {
    Name        = "Main RDS Instance"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# DB Subnet Group - Use all private subnets
resource "aws_db_subnet_group" "main" {
  name       = "terraform-drills-subnet-group"
  subnet_ids = values(aws_subnet.private)[*].id

  tags = {
    Name        = "DB Subnet Group"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
} 

