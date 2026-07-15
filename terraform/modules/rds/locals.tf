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

  cluster_name = "${local.name_prefix}-aurora"

  global_cluster_name = "${local.name_prefix}-global"

  subnet_group_name = "${local.name_prefix}-db-subnet-group"

  parameter_group_name = "${local.name_prefix}-cluster-pg"

  db_parameter_group_name = "${local.name_prefix}-db-pg"

  security_group_name = "${local.name_prefix}-db-sg"

  ###########################################################
  # Common Tags
  ###########################################################

  common_tags = merge(

    var.tags,

    {

      Project = var.project_name

      Environment = var.environment

      ManagedBy = "Terraform"

      Module = "RDS"

    }

  )

}

#############################################################
# Database Subnet Groups
#############################################################

locals {

  primary_db_subnet_group = "${local.name_prefix}-primary-db-subnet-group"

  dr_db_subnet_group = "${local.name_prefix}-dr-db-subnet-group"

}