#############################################################
# Database Security Group
#############################################################

output "database_security_group_id" {

  description = "Aurora Database Security Group ID"

  value = aws_security_group.database.id

}

output "database_security_group_arn" {

  description = "Aurora Database Security Group ARN"

  value = aws_security_group.database.arn

}