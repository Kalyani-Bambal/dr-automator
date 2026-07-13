#############################################################
# OIDC Trust Policy
#############################################################

data "aws_iam_policy_document" "irsa_assume_role" {

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

        "system:serviceaccount:${var.namespace}:${var.service_account_name}"

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