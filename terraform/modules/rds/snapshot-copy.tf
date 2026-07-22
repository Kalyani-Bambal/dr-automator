#############################################################
# RDS Snapshot Configuration
#############################################################

resource "aws_db_snapshot" "manual" {
  count = var.create_manual_snapshot ? 1 : 0

  provider = aws.primary

  db_instance_identifier = aws_db_instance.primary.identifier

  db_snapshot_identifier = "${local.snapshot_identifier}-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  depends_on = [
    aws_db_instance.primary
  ]

  lifecycle {
    ignore_changes = [
      db_snapshot_identifier
    ]
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.snapshot_identifier
      Type = "Manual Snapshot"
    }
  )
}

#############################################################
# Latest Snapshot
#############################################################

data "aws_db_snapshot" "latest" {
  count = var.create_manual_snapshot ? 0 : 0

  provider = aws.primary

  db_instance_identifier = aws_db_instance.primary.identifier

  most_recent = true

  depends_on = [
    aws_db_instance.primary
  ]
}

locals {
  latest_snapshot_arn = try(data.aws_db_snapshot.latest[0].db_snapshot_arn, null)
}