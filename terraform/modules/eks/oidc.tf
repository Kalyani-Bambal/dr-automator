#############################################################
# Retrieve EKS OIDC Certificate
#############################################################

data "tls_certificate" "eks" {

  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

}

#############################################################
# IAM OIDC Identity Provider
#############################################################

resource "aws_iam_openid_connect_provider" "eks" {

  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list = [

    "sts.amazonaws.com"

  ]

  thumbprint_list = [

    data.tls_certificate.eks.certificates[0].sha1_fingerprint

  ]

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-oidc-provider"

      Resource = "EKS OIDC Provider"

    }

  )

}