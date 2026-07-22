#############################################################
# Latest Copied Snapshot (Singapore)
#############################################################

data "aws_db_snapshot" "dr_latest" {
  count = var.enable_dr_restore ? 1 : 0

  provider = aws.dr

  most_recent = true

  db_instance_identifier = local.restore_source_identifier
}

locals {
  dr_snapshot_arn = try(data.aws_db_snapshot.dr_latest[0].db_snapshot_arn, null)
}

#############################################################
# Restore RDS MySQL in DR Region
#############################################################

resource "aws_db_instance" "dr_restore" {

  provider = aws.dr

  ###########################################################
  # Create only when DR restore is enabled
  ###########################################################

  count = var.enable_dr_restore && local.dr_snapshot_arn != null ? 1 : 0

  ###########################################################
  # Restore
  ###########################################################

  identifier = local.restore_identifier

  snapshot_identifier = local.dr_snapshot_arn

  ###########################################################
  # Instance
  ###########################################################

  instance_class = var.dr_instance_class

  ###########################################################
  # Network
  ###########################################################

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.dr.name

  vpc_security_group_ids = [
    var.dr_db_security_group_id
  ]

  ###########################################################
  # Encryption
  ###########################################################

  storage_encrypted = true

  kms_key_id = var.kms_key_arn

  ###########################################################
  # Monitoring
  ###########################################################

  monitoring_interval = var.monitoring_interval

  performance_insights_enabled = var.performance_insights_enabled

  performance_insights_kms_key_id = var.kms_key_arn

  enabled_cloudwatch_logs_exports = local.log_exports

  ###########################################################
  # Protection
  ###########################################################

  deletion_protection = false

  skip_final_snapshot = true

  ###########################################################
  # Tags
  ###########################################################

  tags = merge(
    local.common_tags,
    {
      Name = local.restore_identifier
      Type = "Disaster-Recovery"
      Region = var.dr_region
    }
  )

  ###########################################################
  # Dependencies
  ###########################################################

  depends_on = [
    aws_db_subnet_group.dr
  ]
}