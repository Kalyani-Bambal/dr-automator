#############################################################
# Primary RDS MySQL Instance
#############################################################

resource "aws_db_instance" "primary" {

  provider = aws.primary

  ###########################################################
  # Identification
  ###########################################################

  identifier = local.db_identifier

  ###########################################################
  # Engine
  ###########################################################

  engine         = "mysql"
  engine_version = var.engine_version

  ###########################################################
  # Instance
  ###########################################################

  instance_class = var.instance_class

  ###########################################################
  # Storage
  ###########################################################

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  ###########################################################
  # Database
  ###########################################################

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  ###########################################################
  # Network
  ###########################################################

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.primary.name

  vpc_security_group_ids = [
    var.db_security_group_id
  ]

  ###########################################################
  # Parameter Group
  ###########################################################

  parameter_group_name = aws_db_parameter_group.primary.name

  ###########################################################
  # Backup
  ###########################################################

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window

  copy_tags_to_snapshot = var.copy_tags_to_snapshot

  ###########################################################
  # Maintenance
  ###########################################################

  maintenance_window = var.maintenance_window

  auto_minor_version_upgrade = true

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

  deletion_protection = true

  delete_automated_backups = false

  skip_final_snapshot = false

  final_snapshot_identifier = "${local.db_identifier}-final"

  ###########################################################
  # Availability
  ###########################################################

  multi_az = false

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

  ###########################################################
  # Dependencies
  ###########################################################

  depends_on = [
    aws_db_subnet_group.primary,
    aws_db_parameter_group.primary
  ]
}