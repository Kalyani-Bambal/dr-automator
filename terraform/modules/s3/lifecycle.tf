#############################################################
# Primary Bucket Lifecycle
#############################################################

resource "aws_s3_bucket_lifecycle_configuration" "primary" {

  provider = aws.primary

  count = var.enable_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.primary.id

  rule {

    id = "primary-lifecycle"

    status = "Enabled"

    filter {}

    transition {

      days = var.transition_days

      storage_class = "STANDARD_IA"

    }

    expiration {

      days = var.expiration_days

    }

    noncurrent_version_expiration {

      noncurrent_days = 30

    }

  }

}

#############################################################
# DR Bucket Lifecycle
#############################################################

resource "aws_s3_bucket_lifecycle_configuration" "dr" {

  provider = aws.dr

  count = var.enable_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.dr.id

  rule {

    id = "dr-lifecycle"

    status = "Enabled"

    filter {}

    transition {

      days = var.transition_days

      storage_class = "STANDARD_IA"

    }

    expiration {

      days = var.expiration_days

    }

    noncurrent_version_expiration {

      noncurrent_days = 30

    }

  }

}