#############################################################
# Current AWS Account
#############################################################

data "aws_caller_identity" "current" {}

#############################################################
# Primary Region
#############################################################

data "aws_region" "primary" {

  provider = aws.primary

}

#############################################################
# DR Region
#############################################################

data "aws_region" "dr" {

  provider = aws.dr

}

#############################################################
# Existing Hosted Zone
#############################################################

data "aws_route53_zone" "existing" {

  count = var.create_hosted_zone ? 0 : 1

  name         = var.hosted_zone_name

  private_zone = false

}