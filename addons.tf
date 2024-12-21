# Get current AWS account ID
data "aws_caller_identity" "current" {}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.19.0"

  cluster_name      = aws_eks_cluster.main.name
  cluster_endpoint  = aws_eks_cluster.main.endpoint
  cluster_version   = aws_eks_cluster.main.version
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn

  # Enable AWS Load Balancer Controller
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = aws_vpc.main.id
      },
      {
        name  = "region"
        value = "us-east-1"
      }
    ]
  }

  # Enable NGINX Ingress Controller
  enable_ingress_nginx = true
  ingress_nginx = {
    namespace = "nginx"
    create_namespace = true
    values = [<<-EOT
      controller:
        service:
          type: NodePort
          annotations:
            service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ""
            service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
        config:
          use-forwarded-headers: "true"
          compute-full-forwarded-for: "true"
          ssl-redirect: "false"
    EOT
    ]
  }

  # Enable Cert Manager
  enable_cert_manager = true
  cert_manager = {
    namespace = "cert-manager"
    create_namespace = true
    set = [
      {
        name  = "serviceAccount.name"
        value = "cert-manager"
      },
      {
        name  = "installCRDs"
        value = "true"
      }
    ]
  }

  # Enable External Secrets Operator
  enable_external_secrets = true
  external_secrets = {
    namespace = "external-secrets"
    set = [
      {
        name  = "serviceAccount.name"
        value = "external-secrets"
      }
    ]
  }

  # Configure External Secrets permissions
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:*"]
  external_secrets_ssm_parameter_arns   = ["arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/*"]

  # Enable ArgoCD
  enable_argocd = true
  argocd = {
    namespace = "argo-cd"
    chart_version = "5.46.7"
    set = [
      {
        name  = "server.service.type"
        value = "ClusterIP"
      },
      {
        name  = "server.ingress.enabled"
        value = "false"
      },
      {
        name  = "server.extraArgs[0]"
        value = "--insecure"
      },
      {
        name  = "server.extraArgs[1]"
        value = "--disable-auth"
      },
      {
        name  = "server.certificate.enabled"
        value = "false"
      }
    ]
  }

  # Tags
  tags = {
    Environment = "Dev"
    Project     = "Terraform Drills"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}