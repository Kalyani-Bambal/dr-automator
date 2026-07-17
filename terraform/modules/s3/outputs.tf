#############################################################
# KMS
#############################################################

output "kms_key_id" {

  description = "KMS Key ID"

  value = data.aws_kms_key.primary.key_id

}

output "kms_key_arn" {

  description = "KMS Key ARN"

  value = data.aws_kms_key.primary.arn

}

#############################################################
# Primary Bucket
#############################################################

output "primary_bucket_name" {

  value = aws_s3_bucket.primary.bucket

}

output "primary_bucket_arn" {

  value = aws_s3_bucket.primary.arn

}

output "primary_bucket_id" {

  value = aws_s3_bucket.primary.id

}

#############################################################
# DR Bucket
#############################################################

output "dr_bucket_name" {

  value = aws_s3_bucket.dr.bucket

}

output "dr_bucket_arn" {

  value = aws_s3_bucket.dr.arn

}

output "dr_bucket_id" {

  value = aws_s3_bucket.dr.id

}

#############################################################
# KMS
#############################################################

output "primary_kms_key" {

  value = var.primary_kms_key_arn

}

output "dr_kms_key" {

  value = var.dr_kms_key_arn

}