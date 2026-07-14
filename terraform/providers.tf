#############################################################
# Default AWS Provider
#############################################################

provider "aws" {
  region = var.primary_region

  default_tags {
    tags = local.common_tags
  }
}

#############################################################
# Primary Region
#############################################################

provider "aws" {

  alias = "primary"

  region = var.primary_region

  default_tags {

    tags = local.common_tags

  }

}

#############################################################
# Disaster Recovery Region
#############################################################

provider "aws" {

  alias = "dr"

  region = var.dr_region

  default_tags {

    tags = local.common_tags

  }

}