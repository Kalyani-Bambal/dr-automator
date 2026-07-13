locals {

  common_tags = {

    Project     = "dr-automator"
    Environment = var.environment
    ManagedBy   = "Terraform"

  }

}