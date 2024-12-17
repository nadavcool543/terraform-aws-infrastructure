# ArgoCD Helm Release
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_helm_version
  namespace        = var.argocd_namespace
  create_namespace = true

  # Basic ArgoCD configuration
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Add identification tags
  set {
    name  = "global.labels.Environment"
    value = var.environment
  }

  depends_on = [aws_eks_cluster.main, aws_eks_node_group.main]
} 
