locals {

  ########################################
  # Resource Prefix
  ########################################

  name_prefix = "${var.project_name}-${var.environment}"

  ########################################
  # Common Tags
  ########################################

  common_tags = merge(

    var.tags,

    {

      Project = var.project_name

      Environment = var.environment

      ManagedBy = "Terraform"

      Module = "Security-Groups"

    }

  )

}