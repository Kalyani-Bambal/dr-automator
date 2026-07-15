#############################################################
# Database Security Group
#############################################################

locals {
  database_security_group_id  = var.database_security_group_id != "" ? var.database_security_group_id : aws_security_group.database[0].id

  database_security_group_arn = var.database_security_group_id != "" ? data.aws_security_group.database[0].arn : aws_security_group.database[0].arn
}

#############################################################
# Existing Security Group (Optional)
#############################################################

data "aws_security_group" "database" {

  count = var.database_security_group_id != "" ? 1 : 0

  provider = aws.primary

  id = var.database_security_group_id
}

#############################################################
# Create Security Group
#############################################################

resource "aws_security_group" "database" {

  count = var.database_security_group_id == "" ? 1 : 0

  provider = aws.primary

  name = local.security_group_name

  description = "Security Group for RDS MySQL"

  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = local.security_group_name
    }
  )
}

#############################################################
# Allow MySQL from EKS
#############################################################

resource "aws_vpc_security_group_ingress_rule" "eks_mysql" {

  count = var.database_security_group_id == "" ? 1 : 0

  provider = aws.primary

  security_group_id = aws_security_group.database[0].id

  referenced_security_group_id = var.eks_security_group_id

  ip_protocol = "tcp"

  from_port = 3306

  to_port = 3306

  description = "Allow MySQL access from EKS"
}

#############################################################
# Allow MySQL from Bastion
#############################################################

resource "aws_vpc_security_group_ingress_rule" "bastion_mysql" {

  count = var.database_security_group_id == "" ? 1 : 0

  provider = aws.primary

  security_group_id = aws_security_group.database[0].id

  referenced_security_group_id = var.bastion_security_group_id

  ip_protocol = "tcp"

  from_port = 3306

  to_port = 3306

  description = "Allow MySQL access from Bastion"
}

#############################################################
# Outbound Rule
#############################################################

resource "aws_vpc_security_group_egress_rule" "database_all" {

  count = var.database_security_group_id == "" ? 1 : 0

  provider = aws.primary

  security_group_id = aws_security_group.database[0].id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"

  description = "Allow all outbound traffic"
}