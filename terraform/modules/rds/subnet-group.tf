#############################################################
# Primary DB Subnet Group
#############################################################

resource "aws_db_subnet_group" "primary" {

  provider = aws.primary

  name        = local.primary_db_subnet_group
  description = "Primary RDS MySQL DB Subnet Group"

  subnet_ids = var.private_subnets

  tags = merge(
    local.common_tags,
    {
      Name = local.primary_db_subnet_group
    }
  )

}