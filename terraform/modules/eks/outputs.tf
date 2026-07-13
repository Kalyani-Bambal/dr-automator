#############################################################
# Node Group Name
#############################################################

output "node_group_name" {

  description = "Managed Node Group Name"

  value = aws_eks_node_group.this.node_group_name

}

#############################################################
# Node Group ARN
#############################################################

output "node_group_arn" {

  description = "Managed Node Group ARN"

  value = aws_eks_node_group.this.arn

}

#############################################################
# Node Group Status
#############################################################

output "node_group_status" {

  description = "Managed Node Group Status"

  value = aws_eks_node_group.this.status

}

#############################################################
# Launch Template ID
#############################################################

output "launch_template_id" {

  description = "Launch Template ID"

  value = aws_launch_template.eks.id

}

#############################################################
# OIDC Provider ARN
#############################################################

output "oidc_provider_arn" {

  description = "EKS OIDC Provider ARN"

  value = aws_iam_openid_connect_provider.eks.arn

}

#############################################################
# OIDC Provider URL
#############################################################

output "oidc_provider_url" {

  description = "EKS OIDC Provider URL"

  value = aws_iam_openid_connect_provider.eks.url

}

#############################################################
# OIDC Issuer URL
#############################################################

output "oidc_issuer_url" {

  description = "EKS OIDC Issuer URL"

  value = aws_eks_cluster.this.identity[0].oidc[0].issuer

}

#############################################################
# Amazon VPC CNI
#############################################################

output "vpc_cni_addon_name" {

  description = "Amazon VPC CNI Add-on Name"

  value = aws_eks_addon.vpc_cni.addon_name

}

output "vpc_cni_addon_version" {

  description = "Amazon VPC CNI Version"

  value = aws_eks_addon.vpc_cni.addon_version

}

#############################################################
# CoreDNS
#############################################################

output "coredns_addon_name" {

  description = "CoreDNS Add-on Name"

  value = aws_eks_addon.coredns.addon_name

}

output "coredns_addon_version" {

  description = "CoreDNS Version"

  value = aws_eks_addon.coredns.addon_version

}

#############################################################
# kube-proxy
#############################################################

output "kube_proxy_addon_name" {

  description = "kube-proxy Add-on Name"

  value = aws_eks_addon.kube_proxy.addon_name

}

output "kube_proxy_addon_version" {

  description = "kube-proxy Version"

  value = aws_eks_addon.kube_proxy.addon_version

}

#############################################################
# Amazon EBS CSI Driver
#############################################################

output "ebs_csi_addon_name" {

  description = "Amazon EBS CSI Driver Add-on Name"

  value = aws_eks_addon.ebs_csi_driver.addon_name

}

output "ebs_csi_addon_version" {

  description = "Amazon EBS CSI Driver Version"

  value = aws_eks_addon.ebs_csi_driver.addon_version

}