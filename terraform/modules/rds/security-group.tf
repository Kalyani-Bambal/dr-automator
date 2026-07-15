#############################################################
# Aurora Database Security Group
#############################################################

resource "aws_security_group" "database" {

  provider    = aws.primary

  name        = "${local.name_prefix}-database-sg"

  description = "Security Group for Aurora Database"

  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-database-sg"
    }
  )

}

#############################################################
# Allow MySQL from EKS
#############################################################

resource "aws_vpc_security_group_ingress_rule" "eks_mysql" {

  provider = aws.primary

  security_group_id = aws_security_group.database.id

  referenced_security_group_id = var.eks_security_group_id

  ip_protocol = "tcp"

  from_port = 3306

  to_port = 3306

  description = "Allow MySQL from EKS"

}

#############################################################
# Allow MySQL from Bastion
#############################################################

resource "aws_vpc_security_group_ingress_rule" "bastion_mysql" {

  provider = aws.primary

  security_group_id = aws_security_group.database.id

  referenced_security_group_id = var.bastion_security_group_id

  ip_protocol = "tcp"

  from_port = 3306

  to_port = 3306

  description = "Allow MySQL from Bastion"

}

#############################################################
# Allow All Outbound
#############################################################

resource "aws_vpc_security_group_egress_rule" "database_all" {

  provider = aws.primary

  security_group_id = aws_security_group.database.id

  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"

  description = "Allow all outbound traffic"

}