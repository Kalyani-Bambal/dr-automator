#############################################################
# Route53 Public Hosted Zone
#############################################################

resource "aws_route53_zone" "this" {

  count = var.create_hosted_zone ? 1 : 0

  name = var.hosted_zone_name

  comment = "${local.name_prefix} Public Hosted Zone"

  tags = local.common_tags

}

#############################################################
# Local Hosted Zone ID
#############################################################

locals {

  hosted_zone_id = var.create_hosted_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.existing[0].zone_id

}