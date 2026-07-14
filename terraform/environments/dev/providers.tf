#############################################################
# AWS Providers for dev environment
#############################################################

# Primary region provider (used by modules via aws.primary)
provider "aws" {
  alias  = "primary"
  region = var.primary_region

  default_tags {
    tags = var.tags
  }
}

# Disaster Recovery region provider (if modules need aws.dr)
provider "aws" {
  alias  = "dr"
  region = var.dr_region

  default_tags {
    tags = var.tags
  }
}
