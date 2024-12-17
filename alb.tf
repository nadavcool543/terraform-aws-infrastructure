# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "terraform-drills-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ALB Security Group"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "terraform-drills-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = values(aws_subnet.public)[*].id

  tags = {
    Name        = "Main ALB"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "terraform-drills-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    path               = "/"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "Main Target Group"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}