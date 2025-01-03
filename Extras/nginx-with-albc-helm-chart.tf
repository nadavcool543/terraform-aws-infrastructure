# AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.cleanup.enabled"
    value = "true"
  }

  wait = true
  wait_for_jobs = true
  timeout = 300

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]

}

# Wait for ALB controller to be ready
resource "time_sleep" "wait_for_alb_controller" {
  depends_on = [helm_release.aws_load_balancer_controller]
  create_duration = "180s"
}

# Create IAM role for ALB controller
resource "aws_iam_role" "alb_controller" {
  name = "AWSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller",
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}

# Attach admin policy to ALB controller role
resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.alb_controller.name
}

# Attach policies to ALB controller role
resource "aws_iam_role_policy_attachment" "alb_controller_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.alb_controller.name
}

# NGINX Helm Release
resource "helm_release" "nginx" {
  name             = "nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.7.1"
  namespace        = "nginx"
  create_namespace = true

  # Basic NGINX configuration
  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  # Add identification tags
  set {
    name  = "controller.labels.Environment"
    value = "Dev"
  }

  # Configure health check endpoint
  set {
    name  = "controller.healthCheckPath"
    value = "/healthz"
  }

  set {
    name  = "controller.config.enable-modsecurity"
    value = "false"
  }

  depends_on = [
    helm_release.aws_load_balancer_controller,
    time_sleep.wait_for_alb_controller,
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]

  lifecycle {
    prevent_destroy = false
    ignore_changes = all
  }
}


# ALB Ingress
resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx-ingress"
    namespace = helm_release.nginx.namespace
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "instance"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-port" = "traffic-port"
      "alb.ingress.kubernetes.io/success-codes"    = "200-399"
      "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/certificate-arn"  = "arn:aws:acm:us-east-1:767397741479:certificate/0654c958-3fbc-4214-b355-bb8cba5db57c"
      "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "nginx-ingress-nginx-controller"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.nginx,
    time_sleep.wait_for_alb_controller,
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]
}

# Add this to your nginx.tf
resource "null_resource" "remove_ingress_finalizer" {
  depends_on = [kubernetes_ingress_v1.nginx]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOF
      kubectl patch ingress nginx-ingress -n nginx -p '{"metadata":{"finalizers":[]}}' --type=merge
    EOF
  }
} 