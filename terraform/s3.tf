#S3 Bucket
resource "aws_s3_bucket" "terraform_state" {

  bucket = var.bucket_name

  tags = local.common_tags

}

#Enable Versioning
resource "aws_s3_bucket_versioning" "versioning" {

  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {

    status = "Enabled"

  }

}

#Enable Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {

  bucket = aws_s3_bucket.terraform_state.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"

    }

  }

}

#Block Public Access
resource "aws_s3_bucket_public_access_block" "block" {

  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls = true

  block_public_policy = true

  ignore_public_acls = true

  restrict_public_buckets = true

}

#Enable Bucket Ownership
resource "aws_s3_bucket_ownership_controls" "ownership" {

  bucket = aws_s3_bucket.terraform_state.id

  rule {

    object_ownership = "BucketOwnerPreferred"

  }

}