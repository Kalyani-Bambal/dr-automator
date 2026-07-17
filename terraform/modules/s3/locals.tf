#############################################################
# Local Values
#############################################################

locals {

  ###########################################################
  # Naming
  ###########################################################

  name_prefix = "${var.project_name}-${var.environment}"

  ###########################################################
  # Bucket Names
  ###########################################################

  primary_bucket = var.primary_bucket_name

  dr_bucket = var.dr_bucket_name

  ###########################################################
  # Common Tags
  ###########################################################

  common_tags = merge(

    var.tags,

    {

      Project     = var.project_name

      Environment = var.environment

      Terraform   = "true"

      Module      = "s3"

    }

  )

}

#############################################################
# KMS
#############################################################

locals {

  kms_key_id = data.aws_kms_key.primary.key_id

  kms_key_arn = data.aws_kms_key.primary.arn

}