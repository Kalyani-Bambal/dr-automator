#############################################################
# Amazon VPC CNI
#############################################################

resource "aws_eks_addon" "vpc_cni" {

  cluster_name = aws_eks_cluster.this.name

  addon_name = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-vpc-cni"

      Resource = "EKS Addon"

    }

  )

  depends_on = [

    aws_eks_node_group.this

  ]

}

#############################################################
# CoreDNS
#############################################################

resource "aws_eks_addon" "coredns" {

  cluster_name = aws_eks_cluster.this.name

  addon_name = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-coredns"

      Resource = "EKS Addon"

    }

  )

  depends_on = [

    aws_eks_addon.vpc_cni

  ]

}

#############################################################
# kube-proxy
#############################################################

resource "aws_eks_addon" "kube_proxy" {

  cluster_name = aws_eks_cluster.this.name

  addon_name = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-kube-proxy"

      Resource = "EKS Addon"

    }

  )

  depends_on = [

    aws_eks_addon.coredns

  ]

}

#############################################################
# Amazon EBS CSI Driver
#############################################################

resource "aws_eks_addon" "ebs_csi_driver" {

  cluster_name = aws_eks_cluster.this.name

  addon_name = "aws-ebs-csi-driver"

  service_account_role_arn = var.ebs_csi_role_arn

  resolve_conflicts_on_create = "OVERWRITE"

  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-ebs-csi-driver"

      Resource = "EKS Addon"

    }

  )

  depends_on = [

    aws_iam_openid_connect_provider.eks,

    aws_eks_addon.kube_proxy

  ]

}