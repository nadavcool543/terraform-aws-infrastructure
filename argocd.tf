# ArgoCD Helm Release
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.46.7"
  namespace        = "argocd"
  create_namespace = true

  # Basic ArgoCD configuration
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Add identification tags
  set {
    name  = "global.labels.Environment"
    value = "Dev"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
  ]

  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }
} 