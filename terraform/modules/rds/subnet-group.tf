#############################################################
# Primary RDS DB Subnet Group (Mumbai)
#############################################################

resource "aws_db_subnet_group" "primary" {

  provider = aws.primary

  name        = "${local.subnet_group_name}-primary"
  description = "Primary RDS MySQL Subnet Group"

  subnet_ids = var.private_subnets

  tags = merge(
    local.common_tags,
    {
      Name   = "${local.subnet_group_name}-primary"
      Region = var.primary_region
    }
  )
}

#############################################################
# DR RDS DB Subnet Group (Singapore)
#############################################################

resource "aws_db_subnet_group" "dr" {

  provider = aws.dr

  name        = "${local.subnet_group_name}-dr"
  description = "DR RDS MySQL Subnet Group"

  subnet_ids = var.dr_private_subnets

  tags = merge(
    local.common_tags,
    {
      Name   = "${local.subnet_group_name}-dr"
      Region = var.dr_region
    }
  )
}