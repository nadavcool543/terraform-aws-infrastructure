terraform {
  backend "s3" {
    bucket         = "nadav-terraform-state-bucket01"
    key            = "devops/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "state-locking"
    encrypt        = true
    role_arn       = var.terraform_role_arn
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  assume_role {
    role_arn = var.terraform_role_arn
  }
}

provider "aws" {
  alias  = "dns"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.dns_account_id}:role/${var.route53_role_name}"
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name, "--role-arn", var.terraform_role_arn]
      env = {
        AWS_ROLE_ARN = var.terraform_role_arn
      }
    }
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name, "--role-arn", var.terraform_role_arn]
  }
}
