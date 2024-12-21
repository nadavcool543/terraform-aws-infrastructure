# Wait for ALB controller to be ready
resource "time_sleep" "wait_for_alb_controller" {
  depends_on = [module.eks_blueprints_addons.aws_load_balancer_controller]
  create_duration = "180s"
}

# ALB Ingress for NGINX Controller
resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "ingress-nginx"
    namespace = "nginx"
    annotations = {
     "kubernetes.io/ingress.class"                    = "alb"
     "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
     "alb.ingress.kubernetes.io/target-type"          = "instance"
     "alb.ingress.kubernetes.io/listen-ports"         = jsonencode([{"HTTP" = 80}, {"HTTPS" = 443}])
     "alb.ingress.kubernetes.io/certificate-arn"      = "arn:aws:acm:us-east-1:767397741479:certificate/0654c958-3fbc-4214-b355-bb8cba5db57c"
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
              name = "ingress-nginx-controller"
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
    module.eks_blueprints_addons
  ]
}

# Cleanup finalizer
resource "null_resource" "remove_ingress_finalizer" {
  depends_on = [kubernetes_ingress_v1.nginx]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOF
      kubectl patch ingress ingress-nginx -n nginx -p '{"metadata":{"finalizers":[]}}' --type=merge
    EOF
  }
} 