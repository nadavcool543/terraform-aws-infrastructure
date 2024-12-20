# Use the hosted zone in the EKS account (767397741479)
data "aws_route53_zone" "selected" {
  name = "nshohat.online"
}

# Wait for ALB DNS to be available
data "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx-ingress"
    namespace = "nginx"
  }
  depends_on = [
    kubernetes_ingress_v1.nginx,
    module.eks_blueprints_addons,
    time_sleep.wait_for_alb_dns
  ]
}

# Wait for ALB to be created and DNS to propagate
resource "time_sleep" "wait_for_alb_dns" {
  depends_on = [
    kubernetes_ingress_v1.nginx,
    time_sleep.wait_for_alb_controller
  ]
  create_duration = "300s"
}

# Create Route53 record for ALB
resource "aws_route53_record" "alb" {
  zone_id  = data.aws_route53_zone.selected.zone_id
  name     = "argocd.${data.aws_route53_zone.selected.name}"
  type     = "CNAME"
  ttl      = 300
  records  = [kubernetes_ingress_v1.nginx.status[0].load_balancer[0].ingress[0].hostname]
  depends_on = [
    kubernetes_ingress_v1.nginx,
    module.eks_blueprints_addons,
    time_sleep.wait_for_alb_dns
  ]
}