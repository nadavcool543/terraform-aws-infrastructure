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
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]

  lifecycle {
    prevent_destroy = false
    ignore_changes = all
  }
}

# Cleanup existing ingress before creating new one
resource "null_resource" "cleanup_ingress" {
  triggers = {
    nginx_namespace = helm_release.nginx.namespace
  }

}

# Wait for ALB controller to be ready
resource "time_sleep" "wait_for_alb_controller" {
  depends_on = [module.eks_blueprints_addons.aws_load_balancer_controller]
  create_duration = "180s"
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
      "alb.ingress.kubernetes.io/group.name"       = "nginx"
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
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    null_resource.cleanup_ingress,
    time_sleep.wait_for_alb_controller,
    module.eks_blueprints_addons.aws_load_balancer_controller
  ]

  lifecycle {
    replace_triggered_by = [
      helm_release.nginx,
      aws_eks_cluster.main,
      aws_eks_node_group.main
    ]
  }
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