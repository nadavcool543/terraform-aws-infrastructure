# ArgoCD Outputs
output "argocd_initial_admin_secret" {
  description = "Command to get ArgoCD initial admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_server_load_balancer" {
  description = "ArgoCD server load balancer hostname"
  value       = "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "eks_connect" {
  description = "Command to configure kubectl"
  value       = "aws eks --region us-east-1 update-kubeconfig --name terraform-eks-cluster --role-arn arn:aws:iam::767397741479:role/TerraformRole"
} 