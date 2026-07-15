#############################################################
# Primary DB Subnet Group
#############################################################

resource "aws_db_subnet_group" "primary" {

  provider = aws.primary

  name = local.primary_db_subnet_group

  description = "Aurora Primary DB Subnet Group"

  subnet_ids = var.private_subnets

  tags = merge(

    local.common_tags,

    {

      Name = local.primary_db_subnet_group

      Region = "Primary"

    }

  )

}

#############################################################
# DR DB Subnet Group
#############################################################

resource "aws_db_subnet_group" "dr" {

  provider = aws.dr

  name = local.dr_db_subnet_group

  description = "Aurora DR DB Subnet Group"

  subnet_ids = var.dr_private_subnets

  tags = merge(

    local.common_tags,

    {

      Name = local.dr_db_subnet_group

      Region = "Disaster-Recovery"

    }

  )

}