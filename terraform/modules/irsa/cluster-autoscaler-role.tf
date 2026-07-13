#############################################################
# Cluster Autoscaler IAM Role
#############################################################

resource "aws_iam_role" "cluster_autoscaler" {

  name = "${local.name_prefix}-cluster-autoscaler-role"

  description = "IAM Role for Kubernetes Cluster Autoscaler"

  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role.json

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-cluster-autoscaler-role"

      Resource = "IRSA"

      KubernetesNamespace = "kube-system"

      KubernetesServiceAccount = "cluster-autoscaler"

    }

  )

}

#############################################################
# OIDC Trust Policy
#############################################################

data "aws_iam_policy_document" "cluster_autoscaler_assume_role" {

  statement {

    sid = "IRSAAssumeRole"

    effect = "Allow"

    actions = [

      "sts:AssumeRoleWithWebIdentity"

    ]

    principals {

      type = "Federated"

      identifiers = [

        var.oidc_provider_arn

      ]

    }

    condition {

      test = "StringEquals"

      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"

      values = [

        "system:serviceaccount:kube-system:cluster-autoscaler"

      ]

    }

    condition {

      test = "StringEquals"

      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"

      values = [

        "sts.amazonaws.com"

      ]

    }

  }

}

#############################################################
# Cluster Autoscaler IAM Policy (Part 1)
#############################################################

data "aws_iam_policy_document" "cluster_autoscaler" {

  ###########################################################
  # Auto Scaling Permissions
  ###########################################################

  statement {

    sid = "AutoScaling"

    effect = "Allow"

    actions = [

      "autoscaling:SetDesiredCapacity",

      "autoscaling:TerminateInstanceInAutoScalingGroup",

      "autoscaling:UpdateAutoScalingGroup",

      "autoscaling:DescribeAutoScalingGroups",

      "autoscaling:DescribeAutoScalingInstances",

      "autoscaling:DescribeLaunchConfigurations",

      "autoscaling:DescribeScalingActivities",

      "autoscaling:DescribeTags"

    ]

    resources = [

      "*"

    ]

  }

  ###########################################################
  # EC2 Read Permissions
  ###########################################################

  statement {

    sid = "EC2ReadOnly"

    effect = "Allow"

    actions = [

      "ec2:DescribeImages",

      "ec2:DescribeInstances",

      "ec2:DescribeInstanceTypes",

      "ec2:DescribeLaunchTemplateVersions",

      "ec2:DescribeSubnets",

      "ec2:DescribeSecurityGroups",

      "ec2:DescribeAvailabilityZones",

      "ec2:DescribeVpcs"

    ]

    resources = [

      "*"

    ]

  }

  ###########################################################
  # EKS Read Permissions
  ###########################################################

  statement {

    sid = "EKSReadOnly"

    effect = "Allow"

    actions = [

      "eks:DescribeCluster"

    ]

    resources = [

      "*"

    ]

  }

  ###########################################################
  # Launch Template Read Permissions
  ###########################################################

  statement {

    sid = "LaunchTemplateRead"

    effect = "Allow"

    actions = [

      "ec2:DescribeLaunchTemplates"

    ]

    resources = [

      "*"

    ]

  }

}

#############################################################
# Cluster Autoscaler IAM Policy
#############################################################

resource "aws_iam_policy" "cluster_autoscaler" {

  name = "${local.name_prefix}-cluster-autoscaler-policy"

  description = "IAM Policy for Kubernetes Cluster Autoscaler"

  policy = data.aws_iam_policy_document.cluster_autoscaler.json

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-cluster-autoscaler-policy"

      Resource = "IAM Policy"

    }

  )

}

#############################################################
# IAM Policy Attachment
#############################################################

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {

  role = aws_iam_role.cluster_autoscaler.name

  policy_arn = aws_iam_policy.cluster_autoscaler.arn

}