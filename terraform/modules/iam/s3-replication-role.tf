#############################################################
# S3 Replication Assume Role Policy
#############################################################

data "aws_iam_policy_document" "s3_replication_assume_role" {

  statement {

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

#############################################################
# IAM Role
#############################################################

resource "aws_iam_role" "s3_replication" {

  name = "${local.name_prefix}-s3-replication-role"

  assume_role_policy = data.aws_iam_policy_document.s3_replication_assume_role.json

  tags = local.common_tags
}

#############################################################
# Replication Policy
#############################################################

data "aws_iam_policy_document" "s3_replication_policy" {

  statement {

    sid = "SourceBucket"

    actions = [

      "s3:GetReplicationConfiguration",
      "s3:ListBucket"

    ]

    resources = [
      var.primary_bucket_arn
    ]
  }

  statement {

    sid = "SourceObjects"

    actions = [

      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"

    ]

    resources = [
      "${var.primary_bucket_arn}/*"
    ]
  }

  statement {

    sid = "DestinationBucket"

    actions = [

      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ObjectOwnerOverrideToBucketOwner"

    ]

    resources = [
      "${var.dr_bucket_arn}/*"
    ]
  }

}

#############################################################
# IAM Policy
#############################################################

resource "aws_iam_policy" "s3_replication" {

  name = "${local.name_prefix}-s3-replication-policy"

  policy = data.aws_iam_policy_document.s3_replication_policy.json

}

#############################################################
# Attach Policy
#############################################################

resource "aws_iam_role_policy_attachment" "s3_replication" {

  role = aws_iam_role.s3_replication.name

  policy_arn = aws_iam_policy.s3_replication.arn

}