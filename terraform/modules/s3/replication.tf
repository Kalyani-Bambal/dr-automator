#############################################################
# Cross Region Replication
#############################################################

resource "aws_s3_bucket_replication_configuration" "primary" {

  provider = aws.primary

  count = var.enable_replication ? 1 : 0

  bucket = aws_s3_bucket.primary.id

  role = var.replication_role_arn

  rule {

    id = "replicate-all"

    status = "Enabled"

    filter {}

    destination {

      bucket = aws_s3_bucket.dr.arn

      storage_class = "STANDARD"

      encryption_configuration {

        replica_kms_key_id = var.dr_kms_key_arn

      }

    }

    delete_marker_replication {

      status = "Enabled"

    }

  }

  depends_on = [

    aws_s3_bucket_versioning.primary,
    aws_s3_bucket_versioning.dr

  ]
}