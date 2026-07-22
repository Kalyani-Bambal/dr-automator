#############################################################
# Primary Region Health Check
#############################################################

resource "aws_route53_health_check" "primary" {
  count = var.hosted_zone_name != "" ? 1 : 0

  fqdn = trimsuffix(var.primary_ingress_hostname, ".")

  port = var.health_check_port

  type = var.health_check_protocol

  resource_path = var.health_check_path

  failure_threshold = var.failure_threshold

  request_interval = var.request_interval

  measure_latency = true

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-primary-health-check"

      Region = var.primary_region

    }

  )

}

#############################################################
# DR Region Health Check
#############################################################

resource "aws_route53_health_check" "dr" {
  count = var.hosted_zone_name != "" ? 1 : 0

  fqdn = trimsuffix(var.dr_ingress_hostname, ".")

  port = var.health_check_port

  type = var.health_check_protocol

  resource_path = var.health_check_path

  failure_threshold = var.failure_threshold

  request_interval = var.request_interval

  measure_latency = true

  disabled = false

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-dr-health-check"

      Region = var.dr_region

    }

  )

}