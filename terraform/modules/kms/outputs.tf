#############################################################
# KMS Key ID
#############################################################

output "kms_key_id" {

  description = "KMS Key ID"

  value = aws_kms_key.this.key_id

}

#############################################################
# KMS Key ARN
#############################################################

output "kms_key_arn" {

  description = "KMS Key ARN"

  value = aws_kms_key.this.arn

}

#############################################################
# KMS Alias
#############################################################

output "kms_alias_name" {

  description = "KMS Alias"

  value = aws_kms_alias.this.name

}

#############################################################
# KMS Alias ARN
#############################################################

output "kms_alias_arn" {

  description = "KMS Alias ARN"

  value = aws_kms_alias.this.arn

}