############################################################
# RDS Enhanced Monitoring IAM Role
############################################################

data "aws_iam_policy_document" "rds_monitoring_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${local.name_prefix}-rds-monitoring-role"

  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rds-monitoring-role"
      Resource = "RDS Enhanced Monitoring Role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
