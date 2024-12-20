# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add this ingress rule to allow HTTP from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # Allow traffic from ALB security group
  }

  tags = {
    Name        = "EC2 Security Group"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2023.id  
  instance_type = "t2.micro"
  subnet_id     = values(aws_subnet.public)[0].id  # Gets the first public subnet
  
  vpc_security_group_ids = [aws_security_group.ec2.id]
  
  tags = {
    Name        = "Main Instance"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
} 

