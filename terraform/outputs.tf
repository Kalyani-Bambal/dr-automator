# output "bucket_name" {

#   value = aws_s3_bucket.terraform_state.bucket

# }

# output "bucket_arn" {

#   value = aws_s3_bucket.terraform_state.arn

# }

# output "dynamodb_table" {

#   value = aws_dynamodb_table.terraform_lock.name

# }

#############################################################
# Primary Region
#############################################################

output "primary_region" {

  value = var.primary_region

}

#############################################################
# Disaster Recovery Region
#############################################################

output "dr_region" {

  value = var.dr_region

}

#############################################################
# Disaster Recovery Enabled
#############################################################

output "disaster_recovery_enabled" {

  description = "Disaster Recovery Deployment Status"

  value = var.enable_disaster_recovery

}

#############################################################
# Disaster Recovery Strategy
#############################################################

output "dr_strategy" {

  description = "Configured Disaster Recovery Strategy"

  value = var.dr_strategy

}