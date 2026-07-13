#########################################################
# Current AWS Account
#########################################################

data "aws_caller_identity" "current" {}

#########################################################
# Current AWS Region
#########################################################

data "aws_region" "current" {}

#########################################################
# AWS Partition
#########################################################

data "aws_partition" "current" {}

#########################################################
# KMS Key Policy
#########################################################

data "aws_iam_policy_document" "kms_key_policy" {

  #########################################################
  # Root Account Full Access
  #########################################################

  statement {

    sid    = "EnableRootPermissions"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }

  #########################################################
  # CloudWatch Logs
  #########################################################

  statement {

    sid    = "AllowCloudWatchLogs"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "logs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  }

  #########################################################
  # Allow EC2 / EBS to use the key
  #########################################################

  statement {

    sid    = "AllowEC2EBSUsage"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = [
        "true"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "ec2.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
  }
}