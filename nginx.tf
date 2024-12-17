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
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.terraform_role_arn
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  wait = true
  wait_for_jobs = true
  timeout = 300

  depends_on = [aws_eks_cluster.main, aws_eks_node_group.main]
}

# Wait for ALB controller to be ready
resource "time_sleep" "wait_for_alb_controller" {
  depends_on = [helm_release.aws_load_balancer_controller]
  create_duration = "90s"
}

# NGINX Helm Release
resource "helm_release" "nginx" {
  name             = "nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.nginx_helm_version
  namespace        = var.nginx_namespace
  create_namespace = true

  # Basic NGINX configuration
  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  # Add identification tags
  set {
    name  = "controller.labels.Environment"
    value = var.environment
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

  depends_on = [helm_release.aws_load_balancer_controller]
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
      "alb.ingress.kubernetes.io/certificate-arn"  = var.acm_certificate_arn
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

  depends_on = [helm_release.nginx]
} 