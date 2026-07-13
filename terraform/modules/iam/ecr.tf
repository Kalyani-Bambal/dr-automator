############################################################
# ECR Access Policy Document
############################################################

data "aws_iam_policy_document" "ecr_access" {

  statement {

    sid = "ECRAuthentication"

    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]

  }

  statement {

    sid = "ECRImagePull"

    effect = "Allow"

    actions = [

      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages"

    ]

    resources = ["*"]

  }

}

############################################################
# ECR IAM Policy
############################################################

resource "aws_iam_policy" "ecr_access" {

  name = "${local.name_prefix}-ecr-access"

  description = "Policy for pulling images from Amazon ECR"

  policy = data.aws_iam_policy_document.ecr_access.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ecr-access"
    }
  )

}