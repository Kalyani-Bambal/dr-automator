###################################
# Current AWS Region
###################################

data "aws_region" "current" {}

###################################
# AWS Account
###################################

data "aws_caller_identity" "current" {}

###################################
# Available AZs
###################################

data "aws_availability_zones" "available" {

  state = "available"

}