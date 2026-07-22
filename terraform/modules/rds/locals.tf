#############################################################
# Local Values
#############################################################

locals {

  ###########################################################
  # Naming
  ###########################################################

  name_prefix = "${var.project_name}-${var.environment}"

  ###########################################################
  # Database
  ###########################################################

  db_identifier = "${local.name_prefix}-mysql"

  subnet_group_name = "${local.name_prefix}-db-subnet"

  parameter_group_name = "${local.name_prefix}-mysql-params"

  option_group_name = "${local.name_prefix}-mysql-options"

  ###########################################################
  # Snapshot
  ###########################################################

  snapshot_identifier = "${local.name_prefix}-snapshot"

  restore_identifier = "${local.name_prefix}-mysql-dr"

  restore_source_identifier = local.db_identifier

  ###########################################################
  # Monitoring
  ###########################################################

  log_exports = [
    "error",
    "general",
    "slowquery"
  ]

  ###########################################################
  # Common Tags
  ###########################################################

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      Terraform   = "true"
      Module      = "rds"
    }
  )

}