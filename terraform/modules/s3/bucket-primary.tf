#############################################################
# Primary S3 Bucket (Mumbai)
#############################################################

resource "aws_s3_bucket" "primary" {

  provider = aws.primary

  bucket = var.primary_bucket_name

  force_destroy = false

  tags = merge(
    local.common_tags,
    {
      Name   = var.primary_bucket_name
      Region = var.primary_region
      Type   = "Primary"
    }
  )
}

#############################################################
# DR S3 Bucket (Singapore)
#############################################################

resource "aws_s3_bucket" "dr" {

  provider = aws.dr

  bucket = var.dr_bucket_name

  force_destroy = false

  tags = merge(
    local.common_tags,
    {
      Name   = var.dr_bucket_name
      Region = var.dr_region
      Type   = "DR"
    }
  )
}

#############################################################
# Primary Bucket Versioning
#############################################################

resource "aws_s3_bucket_versioning" "primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.primary.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

#############################################################
# DR Bucket Versioning
#############################################################

resource "aws_s3_bucket_versioning" "dr" {

  provider = aws.dr

  bucket = aws_s3_bucket.dr.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

#############################################################
# Primary Bucket Encryption
#############################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.primary.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "aws:kms"

      kms_master_key_id = var.primary_kms_key_arn

    }

    bucket_key_enabled = true

  }
}

#############################################################
# DR Bucket Encryption
#############################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "dr" {

  provider = aws.dr

  bucket = aws_s3_bucket.dr.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "aws:kms"

      kms_master_key_id = var.dr_kms_key_arn

    }

    bucket_key_enabled = true

  }
}

#############################################################
# Block Public Access - Primary
#############################################################

resource "aws_s3_bucket_public_access_block" "primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.primary.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

#############################################################
# Block Public Access - DR
#############################################################

resource "aws_s3_bucket_public_access_block" "dr" {

  provider = aws.dr

  bucket = aws_s3_bucket.dr.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

#############################################################
# Ownership Controls - Primary
#############################################################

resource "aws_s3_bucket_ownership_controls" "primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.primary.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#############################################################
# Ownership Controls - DR
#############################################################

resource "aws_s3_bucket_ownership_controls" "dr" {

  provider = aws.dr

  bucket = aws_s3_bucket.dr.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}