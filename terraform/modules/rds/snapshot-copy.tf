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
# Copy the primary snapshot into the DR region
#############################################################

resource "aws_db_snapshot_copy" "dr" {
  count = var.enable_dr_restore && var.create_manual_snapshot ? 1 : 0

  provider = aws.dr

  source_db_snapshot_identifier = aws_db_snapshot.manual[0].db_snapshot_arn
  target_db_snapshot_identifier = "${local.snapshot_identifier}-dr"
  copy_tags                    = true
  kms_key_id                   = var.dr_kms_key_arn

  depends_on = [
    aws_db_snapshot.manual
  ]

  tags = merge(
    local.common_tags,
    {
      Name   = "${local.snapshot_identifier}-dr"
      Type   = "Disaster-Recovery-Snapshot"
      Region = var.dr_region
    }
  )
}

locals {
  dr_snapshot_arn = try(aws_db_snapshot_copy.dr[0].db_snapshot_arn, null)
}