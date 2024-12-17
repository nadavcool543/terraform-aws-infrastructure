# General AWS Configuration
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., Dev, Prod)"
  type        = string
  default     = "Dev"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "Terraform-Drills"
}

# Account IDs and Roles
variable "aws_account_id" {
  description = "Main AWS Account ID"
  type        = string
}

variable "dns_account_id" {
  description = "Route53 AWS Account ID"
  type        = string
}

variable "terraform_role_arn" {
  description = "ARN of the Terraform execution role"
  type        = string
}

variable "route53_role_name" {
  description = "Name of the Route53 IAM role"
  type        = string
  default     = "TerraformRoute53Role"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_versioning_enabled" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ec2_ssh_allowed_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# EKS Configuration
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "main-eks-cluster"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.27"
}

variable "eks_node_group_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_group_desired_size" {
  description = "Desired size of EKS node group"
  type        = number
  default     = 2
}

variable "eks_node_group_min_size" {
  description = "Minimum size of EKS node group"
  type        = number
  default     = 1
}

variable "eks_node_group_max_size" {
  description = "Maximum size of EKS node group"
  type        = number
  default     = 3
}

# ArgoCD Configuration
variable "argocd_helm_version" {
  description = "Version of ArgoCD Helm chart"
  type        = string
  default     = "5.46.7"
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

# Domain and Certificate Configuration
variable "domain_name" {
  description = "Base domain name (e.g., nshohat.online)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate"
  type        = string
}

# NGINX Configuration
variable "nginx_helm_version" {
  description = "Version of NGINX Ingress Controller Helm chart"
  type        = string
  default     = "4.7.1"
}

variable "nginx_namespace" {
  description = "Kubernetes namespace for NGINX"
  type        = string
  default     = "nginx"
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# RDS Configuration
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "rds_engine_version" {
  description = "RDS MySQL engine version"
  type        = string
  default     = "8.0"
}

# DynamoDB Configuration
variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity units"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity units"
  type        = number
  default     = 5
}

# Lambda Configuration
variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

# CloudWatch Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

# Auto Scaling Configuration
variable "asg_min_size" {
  description = "Minimum size of Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired capacity of Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_instance_type" {
  description = "Instance type for ASG instances"
  type        = string
  default     = "t2.micro"
}

# Auto Scaling Policy Configuration
variable "scale_up_adjustment" {
  description = "Number of instances to add when scaling up"
  type        = number
  default     = 1
}

variable "scale_down_adjustment" {
  description = "Number of instances to remove when scaling down"
  type        = number
  default     = -1
}

variable "asg_cooldown" {
  description = "Cooldown period in seconds for ASG"
  type        = number
  default     = 300
}

# CloudWatch Alarm Configuration
variable "cpu_high_threshold" {
  description = "CPU utilization threshold for scaling up"
  type        = number
  default     = 80
}

variable "cpu_low_threshold" {
  description = "CPU utilization threshold for scaling down"
  type        = number
  default     = 20
}

variable "alarm_evaluation_periods" {
  description = "Number of periods to evaluate the alarm"
  type        = number
  default     = 2
}

variable "alarm_period" {
  description = "Period in seconds over which to evaluate the alarm"
  type        = number
  default     = 120
}

# S3 and CloudFront Configuration
variable "cloudfront_log_prefix" {
  description = "Prefix for CloudFront logs in S3"
  type        = string
  default     = "cloudfront-logs"
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100" # Use only North America and Europe
}

# Launch Template Configuration
variable "launch_template_name_prefix" {
  description = "Prefix for Launch Template name"
  type        = string
  default     = "terraform-template"
}

# Route53 Configuration
variable "route53_ttl" {
  description = "TTL for Route53 records"
  type        = number
  default     = 300
}

