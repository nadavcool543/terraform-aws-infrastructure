# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "terraform-template"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.ec2.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from EC2" > /var/www/html/index.html
              EOF
  )

  tags = {
    Name        = "Launch Template"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "terraform-drills-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  target_group_arns  = [aws_lb_target_group.main.arn]
  vpc_zone_identifier = values(aws_subnet.public)[*].id

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-drills-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Dev"
    propagate_at_launch = true
  }
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "terraform-drills-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "terraform-drills-scale-down"
  scaling_adjustment     = -1
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# CloudWatch Alarm for High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "terraform-drills-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic          = "Average"
  threshold          = 80
  alarm_description  = "Scale up if CPU > 80%"
  alarm_actions      = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

# CloudWatch Alarm for Low CPU
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "terraform-drills-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic          = "Average"
  threshold          = 20
  alarm_description  = "Scale down if CPU < 20%"
  alarm_actions      = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
} 