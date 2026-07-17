#############################################################
# KMS Key Information
#############################################################

#############################################################
# Primary KMS
#############################################################

data "aws_kms_key" "primary" {

  provider = aws.primary

  key_id = var.primary_kms_key_arn

}

#############################################################
# DR KMS
#############################################################

data "aws_kms_key" "dr" {

  provider = aws.dr

  key_id = var.dr_kms_key_arn

}

#############################################################
# KMS Alias
#############################################################

data "aws_kms_alias" "primary" {

  provider = aws.primary

  name = "alias/${split("/", data.aws_kms_key.primary.key_id)[length(split("/", data.aws_kms_key.primary.key_id)) - 1]}"

  depends_on = [
    data.aws_kms_key.primary
  ]

}

