#############################################################
# KMS Key
#############################################################

resource "aws_kms_key" "this" {

  description = var.kms_key_description

  deletion_window_in_days = var.deletion_window_in_days

  enable_key_rotation = var.enable_key_rotation

  multi_region = var.multi_region

  policy = data.aws_iam_policy_document.kms_key_policy.json

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-kms-key"

      Resource = "KMS Key"

    }

  )

}

#############################################################
# KMS Alias
#############################################################

resource "aws_kms_alias" "this" {

  name = "alias/${local.name_prefix}-kms"

  target_key_id = aws_kms_key.this.key_id

}