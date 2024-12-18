# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "terraform-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = [
      for az in slice(data.aws_availability_zones.available.names, 0, 3) : 
      aws_subnet.private[az].id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = "Main EKS Cluster"
    Environment = "Dev"
    Project     = "Terraform Drills"
  }
}

# Get thumbprint for OIDC
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Configure OIDC Identity Provider
resource "aws_eks_identity_provider_config" "main" {
  cluster_name = aws_eks_cluster.main.name

  oidc {
    client_id                     = "sts.amazonaws.com"
    identity_provider_config_name = "terraform-eks-oidc"
    issuer_url                    = aws_eks_cluster.main.identity[0].oidc[0].issuer
  }
}

# Wait for EKS cluster to be ready
resource "time_sleep" "wait_for_eks" {
  depends_on = [aws_eks_cluster.main]
  create_duration = "30s"
}
  