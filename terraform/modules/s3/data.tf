#############################################################
# Current AWS Account
#############################################################

data "aws_caller_identity" "current" {}

#############################################################
# Current Region
#############################################################

data "aws_region" "primary" {

  provider = aws.primary

}

data "aws_region" "dr" {

  provider = aws.dr

}

#############################################################
# Availability Zones
#############################################################

data "aws_availability_zones" "primary" {

  provider = aws.primary

  state = "available"

}

#############################################################
# Primary KMS
#############################################################

data "aws_kms_key" "primary" {

  provider = aws.primary

  key_id = var.primary_kms_key_arn

}

#############################################################
# DR KMS
#############################################################

data "aws_kms_key" "dr" {

  provider = aws.dr

  key_id = var.dr_kms_key_arn

}