#############################################################
# EKS Cluster
#############################################################

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "EKS Cluster Version"
  value       = aws_eks_cluster.this.version
}

output "cluster_status" {
  description = "EKS Cluster Status"
  value       = aws_eks_cluster.this.status
}

output "cluster_platform_version" {
  description = "EKS Platform Version"
  value       = aws_eks_cluster.this.platform_version
}

output "cluster_certificate_authority_data" {
  description = "Cluster CA Certificate"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Cluster Security Group ID"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

#############################################################
# Node Group
#############################################################

output "node_group_name" {
  description = "Managed Node Group Name"
  value       = aws_eks_node_group.this.node_group_name
}

output "node_group_arn" {
  description = "Managed Node Group ARN"
  value       = aws_eks_node_group.this.arn
}

output "node_group_status" {
  description = "Managed Node Group Status"
  value       = aws_eks_node_group.this.status
}

#############################################################
# Launch Template
#############################################################

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.eks.id
}

#############################################################
# OIDC Provider
#############################################################

output "oidc_provider_arn" {
  description = "EKS OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "EKS OIDC Provider URL"
  value       = aws_iam_openid_connect_provider.eks.url
}

output "oidc_issuer_url" {
  description = "EKS OIDC Issuer URL"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

#############################################################
# Amazon VPC CNI Add-on
#############################################################

output "vpc_cni_addon_name" {
  description = "Amazon VPC CNI Add-on Name"
  value       = aws_eks_addon.vpc_cni.addon_name
}

output "vpc_cni_addon_version" {
  description = "Amazon VPC CNI Version"
  value       = aws_eks_addon.vpc_cni.addon_version
}

#############################################################
# CoreDNS Add-on
#############################################################

output "coredns_addon_name" {
  description = "CoreDNS Add-on Name"
  value       = aws_eks_addon.coredns.addon_name
}

output "coredns_addon_version" {
  description = "CoreDNS Version"
  value       = aws_eks_addon.coredns.addon_version
}

#############################################################
# kube-proxy Add-on
#############################################################

output "kube_proxy_addon_name" {
  description = "kube-proxy Add-on Name"
  value       = aws_eks_addon.kube_proxy.addon_name
}

output "kube_proxy_addon_version" {
  description = "kube-proxy Version"
  value       = aws_eks_addon.kube_proxy.addon_version
}

#############################################################
# Amazon EBS CSI Driver Add-on
#############################################################

output "ebs_csi_addon_name" {
  description = "Amazon EBS CSI Driver Add-on Name"
  value       = aws_eks_addon.ebs_csi_driver.addon_name
}

output "ebs_csi_addon_version" {
  description = "Amazon EBS CSI Driver Version"
  value       = aws_eks_addon.ebs_csi_driver.addon_version
}