#############################################################
# Database Security Group
#############################################################

output "database_security_group_id" {
  description = "Database Security Group ID"
  value       = local.database_security_group_id
}

output "database_security_group_arn" {
  description = "Database Security Group ARN"
  value       = local.database_security_group_arn
}

#############################################################
# Parameter Group
#############################################################

output "db_parameter_group_name" {
  description = "MySQL DB Parameter Group"
  value       = aws_db_parameter_group.database.name
}

#############################################################
# Subnet Group
#############################################################

output "db_subnet_group_name" {
  description = "DB Subnet Group Name"
  value       = aws_db_subnet_group.primary.name
}

#############################################################
# Primary RDS Instance
#############################################################

output "db_instance_id" {
  description = "RDS Instance ID"
  value       = aws_db_instance.primary.id
}

output "db_instance_arn" {
  description = "RDS Instance ARN"
  value       = aws_db_instance.primary.arn
}

output "db_instance_identifier" {
  description = "RDS Identifier"
  value       = aws_db_instance.primary.identifier
}

output "db_instance_endpoint" {
  description = "Database Endpoint"
  value       = aws_db_instance.primary.endpoint
}

output "db_instance_address" {
  description = "Database Address"
  value       = aws_db_instance.primary.address
}

output "db_instance_port" {
  description = "Database Port"
  value       = aws_db_instance.primary.port
}

output "db_instance_resource_id" {
  description = "RDS Resource ID"
  value       = aws_db_instance.primary.resource_id
}

output "db_instance_name" {
  description = "Database Name"
  value       = aws_db_instance.primary.db_name
}

output "db_instance_engine" {
  description = "Database Engine"
  value       = aws_db_instance.primary.engine
}

output "db_instance_engine_version" {
  description = "Database Engine Version"
  value       = aws_db_instance.primary.engine_version
}

output "db_instance_status" {
  description = "Database Status"
  value       = aws_db_instance.primary.status
}