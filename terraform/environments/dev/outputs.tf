output "vpc_id" {

  value = module.vpc.vpc_id

}

output "public_subnets" {

  value = module.vpc.public_subnets

}

output "private_subnets" {

  value = module.vpc.private_subnets

}

#############################################################
# Primary EKS Cluster
#############################################################

output "primary_cluster_name" {

  value = module.eks.cluster_name

}

output "primary_cluster_endpoint" {

  value = module.eks.cluster_endpoint

}

#########################################################
# Security Groups
#########################################################

output "alb_security_group_id" {

  value = module.security_groups.alb_security_group_id

}

output "eks_cluster_security_group_id" {

  value = module.security_groups.eks_cluster_security_group_id

}

output "node_security_group_id" {

  value = module.security_groups.node_security_group_id

}

output "database_security_group_id" {

  value = module.security_groups.database_security_group_id

}

output "bastion_security_group_id" {

  value = module.security_groups.bastion_security_group_id

}

#############################################################
# KMS Outputs
#############################################################

output "kms_key_id" {

  value = module.kms.kms_key_id

}

output "kms_key_arn" {

  value = module.kms.kms_key_arn

}

output "kms_alias_name" {

  value = module.kms.kms_alias_name

}

output "kms_alias_arn" {

  value = module.kms.kms_alias_arn

}

#############################################################
# OIDC Provider ARN
#############################################################

output "oidc_provider_arn" {

  value = module.eks.oidc_provider_arn

}

#############################################################
# OIDC Provider URL
#############################################################

output "oidc_provider_url" {

  value = module.eks.oidc_provider_url

}

#############################################################
# OIDC Issuer URL
#############################################################

output "oidc_issuer_url" {

  value = module.eks.oidc_issuer_url

}

#############################################################
# Amazon VPC CNI
#############################################################

output "vpc_cni_addon_name" {

  value = module.eks.vpc_cni_addon_name

}

output "vpc_cni_addon_version" {

  value = module.eks.vpc_cni_addon_version

}

#############################################################
# CoreDNS
#############################################################

output "coredns_addon_name" {

  value = module.eks.coredns_addon_name

}

output "coredns_addon_version" {

  value = module.eks.coredns_addon_version

}

#############################################################
# kube-proxy
#############################################################

output "kube_proxy_addon_name" {

  value = module.eks.kube_proxy_addon_name

}

output "kube_proxy_addon_version" {

  value = module.eks.kube_proxy_addon_version

}

#############################################################
# Amazon EBS CSI Driver
#############################################################

output "ebs_csi_addon_name" {

  value = module.eks.ebs_csi_addon_name

}

output "ebs_csi_addon_version" {

  value = module.eks.ebs_csi_addon_version

}

output "cluster_autoscaler_role_arn" {

  value = module.irsa.cluster_autoscaler_role_arn

}

output "cluster_autoscaler_policy_arn" {

  value = module.irsa.cluster_autoscaler_policy_arn

}
#############################################################
# Amazon EBS CSI Driver
#############################################################

output "ebs_csi_driver_role_arn" {

  value = module.irsa.ebs_csi_driver_role_arn

}

#############################################################
# AWS Load Balancer Controller
#############################################################

output "aws_load_balancer_controller_role_arn" {

  value = module.irsa.aws_load_balancer_controller_role_arn

}

#############################################################
# Disaster Recovery Outputs
#############################################################

output "dr_region" {

  value = var.dr_region

}

output "dr_enabled" {

  value = var.enable_disaster_recovery

}

output "dr_strategy" {

  value = var.dr_strategy

}