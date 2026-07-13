############################################################
# CloudWatch Policy Document
############################################################

data "aws_iam_policy_document" "cloudwatch_access" {

  statement {

    sid = "CloudWatchLogs"

    effect = "Allow"

    actions = [

      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents"

    ]

    resources = ["*"]

  }

  statement {

    sid = "CloudWatchMetrics"

    effect = "Allow"

    actions = [

      "cloudwatch:PutMetricData"

    ]

    resources = ["*"]

  }

}

############################################################
# CloudWatch IAM Policy
############################################################

resource "aws_iam_policy" "cloudwatch_access" {

  name = "${local.name_prefix}-cloudwatch-access"

  description = "CloudWatch Logs and Metrics Policy"

  policy = data.aws_iam_policy_document.cloudwatch_access.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-cloudwatch-access"
    }
  )

}