############################################################
# EKS Cluster IAM Role
############################################################

resource "aws_iam_role" "eks_cluster" {

  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-eks-cluster-role"

      Resource = "EKS Cluster IAM Role"

    }

  )

}

############################################################
# AmazonEKSClusterPolicy
############################################################

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"

}

############################################################
# AmazonEKSVPCResourceController
############################################################

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {

  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSVPCResourceController"

}

############################################################
# CloudWatch Logs
############################################################

resource "aws_iam_role_policy_attachment" "eks_cloudwatch_logs" {

  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchLogsFullAccess"

}