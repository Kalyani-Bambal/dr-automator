#############################################################
# Hosted Zone
#############################################################

output "hosted_zone_id" {

  description = "Route53 Hosted Zone ID"

  value = local.hosted_zone_id

}

output "hosted_zone_name" {

  description = "Hosted Zone Name"

  value = var.hosted_zone_name

}

output "name_servers" {

  description = "Hosted Zone Name Servers"

  value = var.create_hosted_zone ? aws_route53_zone.this[0].name_servers : []

}

#############################################################
# Health Checks
#############################################################

output "primary_health_check_id" {

  description = "Primary Route53 Health Check"

  value = var.hosted_zone_name != "" ? aws_route53_health_check.primary[0].id : null

}

output "dr_health_check_id" {

  description = "DR Route53 Health Check"

  value = var.hosted_zone_name != "" ? aws_route53_health_check.dr[0].id : null

}

#############################################################
# DNS Records
#############################################################

output "primary_record_fqdn" {

  description = "Primary DNS Record"

  value = var.hosted_zone_name != "" ? aws_route53_record.primary[0].fqdn : null

}

output "secondary_record_fqdn" {

  description = "Secondary DNS Record"

  value = var.hosted_zone_name != "" ? aws_route53_record.secondary[0].fqdn : null

}