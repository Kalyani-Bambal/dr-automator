#############################################################
# Amazon EKS Cluster
#############################################################

resource "aws_eks_cluster" "this" {
  name                      = var.cluster_name
  version                   = var.cluster_version
  role_arn                  = var.cluster_role_arn
  enabled_cluster_log_types = var.enabled_cluster_log_types

  depends_on = [
    aws_cloudwatch_log_group.eks,
  ]

  vpc_config {
    subnet_ids              = var.private_subnets
    security_group_ids      = [var.cluster_security_group_id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.public_access_cidrs
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }

    resources = ["secrets"]
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  tags = merge(
    local.common_tags,
    {
      Name     = "${local.name_prefix}-eks"
      Resource = "EKS Cluster"
    }
  )
}

#############################################################
# CloudWatch Log Group
#############################################################

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.kms_key_arn

  tags = merge(
    local.common_tags,
    {
      Name     = "${local.name_prefix}-eks-log-group"
      Resource = "CloudWatch"
    }
  )
}