#############################################################
# AWS Load Balancer Controller IAM Role
#############################################################

resource "aws_iam_role" "aws_load_balancer_controller" {

  name = "${local.name_prefix}-aws-load-balancer-controller-role"

  description = "IAM Role for AWS Load Balancer Controller"

  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role.json

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-aws-load-balancer-controller-role"

      Resource = "IRSA"

      KubernetesNamespace = "kube-system"

      KubernetesServiceAccount = "aws-load-balancer-controller"

    }

  )

}

#############################################################
# OIDC Trust Policy
#############################################################

data "aws_iam_policy_document" "alb_controller_assume_role" {

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

        "system:serviceaccount:kube-system:aws-load-balancer-controller"

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
# AWS Load Balancer Controller IAM Policy Document
#############################################################

data "aws_iam_policy_document" "aws_load_balancer_controller" {
  statement {
    sid    = "ALBController"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole",
      "ec2:Describe*",
      "elasticloadbalancing:Describe*",
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:GetWebACL",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:ModifyInstanceAttribute",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule"
    ]

    resources = [
      "*"
    ]
  }
}

#############################################################
# AWS Load Balancer Controller IAM Policy
#############################################################

resource "aws_iam_policy" "aws_load_balancer_controller" {

  name = "${local.name_prefix}-aws-load-balancer-controller-policy"

  description = "IAM Policy for AWS Load Balancer Controller"

  policy = data.aws_iam_policy_document.aws_load_balancer_controller.json

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-aws-load-balancer-controller-policy"

      Resource = "IAM Policy"

    }

  )

}

#############################################################
# IAM Policy Attachment
#############################################################

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {

  role = aws_iam_role.aws_load_balancer_controller.name

  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn

}