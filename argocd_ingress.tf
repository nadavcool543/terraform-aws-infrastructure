# Wait for NGINX controller webhook to be ready
resource "time_sleep" "wait_for_nginx" {
  depends_on = [module.eks_blueprints_addons]
  create_duration = "60s"
}

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-server-ingress"
    namespace = "argo-cd"
    annotations = {
      "kubernetes.io/ingress.class"                  = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "argocd.nshohat.online"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argo-cd-argocd-server"
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
    time_sleep.wait_for_nginx,
    kubernetes_ingress_v1.nginx,
    module.eks_blueprints_addons
  ]
} 