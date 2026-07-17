#############################################################
# Primary Failover Record
#############################################################

resource "aws_route53_record" "primary" {

  zone_id = local.hosted_zone_id

  name = var.hosted_zone_name

  type = "A"

  set_identifier = "primary"

  failover_routing_policy {

    type = "PRIMARY"

  }

  health_check_id = aws_route53_health_check.primary.id

  alias {

    name    = var.primary_ingress_hostname
    zone_id = var.primary_ingress_zone_id

    evaluate_target_health = true

  }

}

#############################################################
# DR Failover Record
#############################################################

resource "aws_route53_record" "secondary" {

  zone_id = local.hosted_zone_id

  name = var.hosted_zone_name

  type = "A"

  set_identifier = "secondary"

  failover_routing_policy {

    type = "SECONDARY"

  }

  health_check_id = aws_route53_health_check.dr.id

  alias {

    name    = var.dr_ingress_hostname
    zone_id = var.dr_ingress_zone_id

    evaluate_target_health = true

  }

}