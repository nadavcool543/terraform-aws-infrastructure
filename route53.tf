# Get the hosted zone
data "aws_route53_zone" "selected" {
  provider = aws.dns
  name = "${var.domain_name}."
}

# Wait for ALB DNS to be available
data "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx-ingress"
    namespace = "nginx"
  }
  depends_on = [kubernetes_ingress_v1.nginx]
}

# Create Route53 record for ALB
resource "aws_route53_record" "alb" {
  provider = aws.dns
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.argocd_namespace}.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = var.route53_ttl
  records = [data.kubernetes_ingress_v1.nginx.status[0].load_balancer[0].ingress[0].hostname]
}

# ACM Certificate validation record
resource "aws_route53_record" "cert_validation" {
  provider = aws.dns
  name    = "_50fa5a1e53308bcf58ba360a4fe99ee7.${var.argocd_namespace}.${var.domain_name}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.selected.zone_id
  records = ["_50c88497e681b05350bf35c2e5298b31.zfyfvmchrl.acm-validations.aws"]
  ttl     = var.route53_ttl
}

# Get ArgoCD ingress details
data "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
} 