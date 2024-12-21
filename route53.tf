# Get the ELB hosted zone ID
data "aws_elb_hosted_zone_id" "main" {}

# Use the hosted zone in the EKS account (767397741479)
data "aws_route53_zone" "selected" {
  name = "nshohat.online"
}

# Wait for ALB DNS to be available
data "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx-ingress"
    namespace = "argo-cd"
  }
  depends_on = [
    kubernetes_ingress_v1.nginx,
    module.eks_blueprints_addons,
    time_sleep.wait_for_alb_dns
  ]
}

# Check if ALB hostname exists
locals {
  alb_hostname = try(kubernetes_ingress_v1.nginx.status[0].load_balancer[0].ingress[0].hostname, "")
  create_record = local.alb_hostname != ""
}

# Wait for ALB to be created and DNS to propagate
resource "time_sleep" "wait_for_alb_dns" {
  depends_on = [
    kubernetes_ingress_v1.nginx,
    time_sleep.wait_for_alb_controller
  ]
  create_duration = "300s"
}

# Wait for ALB to be created
resource "time_sleep" "wait_for_alb" {
  depends_on = [kubernetes_ingress_v1.nginx]
  create_duration = "30s"
}

# Create Route53 record for ALB
resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    name                   = kubernetes_ingress_v1.nginx.status[0].load_balancer[0].ingress[0].hostname
    zone_id               = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [
    kubernetes_ingress_v1.nginx,
    time_sleep.wait_for_alb
  ]
}