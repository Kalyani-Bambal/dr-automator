############################################################
# EKS Worker Node IAM Role
############################################################

resource "aws_iam_role" "node_group" {

  name = "${local.name_prefix}-node-group-role"

  assume_role_policy = data.aws_iam_policy_document.node_group_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name     = "${local.name_prefix}-node-group-role"
      Resource = "EKS Worker Node IAM Role"
    }
  )

}

############################################################
# AmazonEKSWorkerNodePolicy
############################################################

resource "aws_iam_role_policy_attachment" "worker_node_policy" {

  role = aws_iam_role.node_group.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

############################################################
# Amazon ECR Pull Access
############################################################

resource "aws_iam_role_policy_attachment" "ecr_pull_policy" {

  role = aws_iam_role.node_group.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"

}

############################################################
# AmazonEKS_CNI_Policy
############################################################

resource "aws_iam_role_policy_attachment" "cni_policy" {

  role = aws_iam_role.node_group.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"

}

############################################################
# AWS Systems Manager
############################################################

resource "aws_iam_role_policy_attachment" "ssm_policy" {

  role = aws_iam_role.node_group.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

############################################################
# Instance Profile
############################################################

resource "aws_iam_instance_profile" "node_group" {

  name = "${local.name_prefix}-node-instance-profile"

  role = aws_iam_role.node_group.name

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-node-instance-profile"
    }
  )

}