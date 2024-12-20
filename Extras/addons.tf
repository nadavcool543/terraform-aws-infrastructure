# AWS Load Balancer Controller Addon
resource "aws_eks_addon" "aws_load_balancer_controller" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-load-balancer-controller"

  # Use latest version by not specifying addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  
  service_account_role_arn = aws_iam_role.alb_controller.arn

  tags = {
    "Environment" = "Dev"
    "Project"     = "Terraform Drills"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_iam_role.alb_controller
  ]
}

# EBS CSI Driver Addon
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  
  service_account_role_arn = aws_iam_role.ebs_csi_controller.arn

  tags = {
    "Environment" = "Dev"
    "Project"     = "Terraform Drills"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_iam_role.ebs_csi_controller
  ]
} 