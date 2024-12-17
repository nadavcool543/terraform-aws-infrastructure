<<<<<<< HEAD
# AWS Infrastructure as Code with Terraform

This repository contains Terraform configurations for deploying a complete AWS infrastructure including EKS, ArgoCD, ALB, and supporting services.

## Infrastructure Components

- **VPC & Networking**
  - Custom VPC with public/private subnets
  - Internet Gateway and NAT Gateway
  - Route tables and security groups

- **Kubernetes (EKS)**
  - Managed EKS cluster
  - Node groups with autoscaling
  - NGINX Ingress Controller
  - ArgoCD deployment

- **Load Balancing & DNS**
  - Application Load Balancer (ALB)
  - Route53 DNS management
  - ACM certificate integration

- **Additional Services**
  - S3 bucket with CloudFront distribution
  - DynamoDB tables
  - Lambda functions
  - RDS database
  - Auto Scaling Groups

## Prerequisites

1. AWS CLI installed and configured
2. Terraform (version ~> 1.0)
3. kubectl
4. AWS IAM permissions for:
   - EKS
   - EC2
   - VPC
   - Route53
   - IAM
   - S3
   - DynamoDB
   - Lambda
   - RDS

## Quick Start

1. Clone the repository: git clone https://github.com/nadavcool543/terraform-aws-infrastructure.git
2. Navigate to the infrastructure directory: cd terraform-aws-infrastructure
3. Create a `terraform.tfvars` file based on example: cp example.tfvars terraform.tfvars
4. Initialize Terraform: terraform init
5. Review the deployment plan: terraform plan
6. Apply the configuration: terraform apply


## Configuration

Key variables that can be configured in `terraform.tfvars`:

- `aws_region`: AWS region for deployment
- `environment`: Environment name (Dev, Prod, etc.)
- `project_name`: Project identifier
- `domain_name`: Base domain for DNS
- `eks_cluster_version`: Kubernetes version
- `vpc_cidr`: VPC CIDR block

## Architecture
Route53 → ALB → NGINX Controller → ArgoCD


## Maintenance

- **State Management**: Stored in S3 with DynamoDB locking
- **Updates**: Use `terraform plan` to review changes
- **Cleanup**: Use `terraform destroy` to remove all resources

## Security Considerations

- All sensitive values should be provided via `terraform.tfvars`
- IAM roles use least-privilege principle
- VPC endpoints for enhanced security
- Private subnets for sensitive resources

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
=======
# AWS Infrastructure as Code with Terraform

This repository contains Terraform configurations for deploying a complete AWS infrastructure including EKS, ArgoCD, ALB, and supporting services.

## Infrastructure Components

- **VPC & Networking**
  - Custom VPC with public/private subnets
  - Internet Gateway and NAT Gateway
  - Route tables and security groups

- **Kubernetes (EKS)**
  - Managed EKS cluster
  - Node groups with autoscaling
  - NGINX Ingress Controller
  - ArgoCD deployment

- **Load Balancing & DNS**
  - Application Load Balancer (ALB)
  - Route53 DNS management
  - ACM certificate integration

- **Additional Services**
  - S3 bucket with CloudFront distribution
  - DynamoDB tables
  - Lambda functions
  - RDS database
  - Auto Scaling Groups

## Prerequisites

1. AWS CLI installed and configured
2. Terraform (version ~> 1.0)
3. kubectl
4. AWS IAM permissions for:
   - EKS
   - EC2
   - VPC
   - Route53
   - IAM
   - S3
   - DynamoDB
   - Lambda
   - RDS

## Quick Start

1. Clone the repository: 
>>>>>>> 17a0405 (new v)
