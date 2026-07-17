#############################################################
# Primary RDS
#############################################################

output "db_instance_id" {
  description = "Primary RDS Instance ID"
  value       = aws_db_instance.primary.id
}

output "db_instance_identifier" {
  description = "Primary RDS Identifier"
  value       = aws_db_instance.primary.identifier
}

output "db_instance_arn" {
  description = "Primary RDS ARN"
  value       = aws_db_instance.primary.arn
}

output "db_instance_endpoint" {
  description = "Primary RDS Endpoint"
  value       = aws_db_instance.primary.address
}

output "db_instance_port" {
  description = "Primary RDS Port"
  value       = aws_db_instance.primary.port
}

output "db_name" {
  description = "Database Name"
  value       = aws_db_instance.primary.db_name
}

#############################################################
# Primary Subnet Group
#############################################################

output "db_subnet_group_name" {
  description = "Primary DB Subnet Group"
  value       = aws_db_subnet_group.primary.name
}

#############################################################
# Parameter Group
#############################################################

output "parameter_group_name" {
  description = "Parameter Group"
  value       = aws_db_parameter_group.primary.name
}

#############################################################
# DR Subnet Group
#############################################################

output "dr_subnet_group_name" {
  description = "DR DB Subnet Group"
  value       = aws_db_subnet_group.dr.name
}

#############################################################
# Restore Configuration
#############################################################

output "restore_identifier" {
  description = "DR Restore Identifier"
  value       = local.restore_identifier
}

#############################################################
# Snapshot Information
#############################################################

output "snapshot_identifier" {
  description = "Snapshot Identifier"
  value       = local.snapshot_identifier
}

#############################################################
# DR Restore Endpoint
#############################################################

output "dr_endpoint" {
  description = "DR Database Endpoint"

  value = var.enable_dr_restore ? aws_db_instance.dr_restore[0].address : null
}

#############################################################
# Tags
#############################################################

output "tags" {
  description = "Common Tags"
  value       = local.common_tags
}