# Wait for NGINX controller webhook to be ready
resource "time_sleep" "wait_for_nginx" {
  depends_on = [helm_release.nginx]
  create_duration = "60s"
}

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-server-ingress"
    namespace = helm_release.argocd.namespace
    annotations = {
      "kubernetes.io/ingress.class"                  = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "cert-manager.io/cluster-issuer"               = "letsencrypt-prod"
    }
  }

  spec {
    tls {
      hosts       = ["argocd.nshohat.online"]
      secret_name = "argocd-cert-tls"
    }
    ingress_class_name = "nginx"
    rule {
      host = "argocd.${data.aws_route53_zone.selected.name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    time_sleep.wait_for_nginx,
    kubernetes_ingress_v1.nginx
  ]
} 