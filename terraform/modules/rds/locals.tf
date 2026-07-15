#############################################################
# Local Values
#############################################################

locals {

  ###########################################################
  # Resource Prefix
  ###########################################################

  name_prefix = "${var.project_name}-${var.environment}"

  ###########################################################
  # Database Naming
  ###########################################################

  db_identifier        = "${local.name_prefix}-mysql"

  subnet_group_name    = "${local.name_prefix}-db-subnet-group"

  parameter_group_name = "${local.name_prefix}-mysql-pg"

  security_group_name  = "${local.name_prefix}-database-sg"

  ###########################################################
  # Common Tags
  ###########################################################

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "RDS"
    }
  )

}

#############################################################
# Database Subnet Group
#############################################################

locals {

  primary_db_subnet_group = "${local.name_prefix}-primary-db-subnet-group"

}