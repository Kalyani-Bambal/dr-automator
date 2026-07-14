#############################################################
# Local Values
#############################################################

locals {

  ###########################################################
  # Naming Convention
  ###########################################################

  name_prefix = "${var.project_name}-${var.environment}"

  ###########################################################
  # Primary Region
  ###########################################################

  primary = {

    name = "Mumbai"

    region = var.primary_region

    short = "mum"

  }

  ###########################################################
  # Disaster Recovery Region
  ###########################################################

  disaster_recovery = {

    name = "Singapore"

    region = var.dr_region

    short = "sg"

  }

  ###########################################################
  # Region Mapping
  ###########################################################

  region_map = {

    primary = {

      region = var.primary_region

      azs = var.primary_azs

    }

    dr = {

      region = var.dr_region

      azs = var.dr_azs

    }

  }

  ###########################################################
  # Common Tags
  ###########################################################

  common_tags = merge(

    var.tags,

    {

      Project = var.project_name

      Environment = var.environment

      ManagedBy = "Terraform"

      PrimaryRegion = var.primary_region

      DisasterRecoveryRegion = var.dr_region

      DisasterRecoveryEnabled = tostring(var.enable_disaster_recovery)

      DisasterRecoveryStrategy = var.dr_strategy

      RTO = "${var.rto_minutes} Minutes"

      RPO = "${var.rpo_minutes} Minutes"

    }

  )

}