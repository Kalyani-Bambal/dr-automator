#############################################################
# Primary RDS MySQL Instance
#############################################################

resource "aws_db_instance" "primary" {

  provider = aws.primary

  ###########################################################
  # Database Configuration
  ###########################################################

  identifier     = local.db_identifier

  engine         = var.engine
  engine_version = var.engine_version

  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  port = var.database_port

  ###########################################################
  # Storage
  ###########################################################

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  storage_type      = var.storage_type
  storage_encrypted = true

  kms_key_id = var.kms_key_arn

  ###########################################################
  # Network
  ###########################################################

  db_subnet_group_name = aws_db_subnet_group.primary.name

  vpc_security_group_ids = [
    local.database_security_group_id
  ]

  publicly_accessible = false

  ###########################################################
  # Parameter Group
  ###########################################################

  parameter_group_name = aws_db_parameter_group.database.name

  ###########################################################
  # Backup
  ###########################################################

  backup_retention_period = var.backup_retention_period

  backup_window = var.preferred_backup_window

  maintenance_window = var.preferred_maintenance_window

  copy_tags_to_snapshot = true

  ###########################################################
  # Monitoring
  ###########################################################

  monitoring_interval = var.monitoring_interval

  monitoring_role_arn = var.monitoring_role_arn

  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]

  performance_insights_enabled = true

  ###########################################################
  # Protection
  ###########################################################

  deletion_protection = true

  skip_final_snapshot     = false
  final_snapshot_identifier = "${local.db_identifier}-final"

  auto_minor_version_upgrade = true

  apply_immediately = false

  ###########################################################
  # Tags
  ###########################################################

  tags = merge(
    local.common_tags,
    {
      Name = local.db_identifier
      Type = "Primary"
    }
  )

}