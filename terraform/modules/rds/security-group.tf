#############################################################
# Primary Database Security Group
#############################################################

resource "aws_security_group" "primary_db" {

  provider = aws.primary

  name        = "${local.name_prefix}-mysql-sg"
  description = "Primary MySQL Security Group"

  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-mysql-sg"
    }
  )
}

#############################################################
# Allow MySQL from EKS
#############################################################

resource "aws_vpc_security_group_ingress_rule" "primary_from_eks" {

  provider = aws.primary

  security_group_id = aws_security_group.primary_db.id

  referenced_security_group_id = var.eks_security_group_id

  from_port = var.db_port
  to_port   = var.db_port

  ip_protocol = "tcp"

  description = "Allow MySQL from EKS"
}

#############################################################
# Allow MySQL from Bastion
#############################################################

resource "aws_vpc_security_group_ingress_rule" "primary_from_bastion" {

  provider = aws.primary

  security_group_id = aws_security_group.primary_db.id

  referenced_security_group_id = var.bastion_security_group_id

  from_port = var.db_port
  to_port   = var.db_port

  ip_protocol = "tcp"

  description = "Allow MySQL from Bastion"
}

#############################################################
# Outbound
#############################################################

resource "aws_vpc_security_group_egress_rule" "primary_all" {

  provider = aws.primary

  security_group_id = aws_security_group.primary_db.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}

#############################################################
# DR Database Security Group
#############################################################

resource "aws_security_group" "dr_db" {

  provider = aws.dr

  name        = "${local.name_prefix}-mysql-dr-sg"
  description = "DR MySQL Security Group"

  vpc_id = var.dr_vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-mysql-dr-sg"
    }
  )
}

#############################################################
# Allow MySQL from DR EKS
#############################################################

resource "aws_vpc_security_group_ingress_rule" "dr_from_eks" {

  provider = aws.dr

  security_group_id = aws_security_group.dr_db.id

  referenced_security_group_id = var.eks_security_group_id

  from_port = var.db_port
  to_port   = var.db_port

  ip_protocol = "tcp"

  description = "Allow MySQL from DR EKS"
}

#############################################################
# Allow MySQL from DR Bastion
#############################################################

resource "aws_vpc_security_group_ingress_rule" "dr_from_bastion" {

  provider = aws.dr

  security_group_id = aws_security_group.dr_db.id

  referenced_security_group_id = var.bastion_security_group_id

  from_port = var.db_port
  to_port   = var.db_port

  ip_protocol = "tcp"

  description = "Allow MySQL from DR Bastion"
}

#############################################################
# Outbound
#############################################################

resource "aws_vpc_security_group_egress_rule" "dr_all" {

  provider = aws.dr

  security_group_id = aws_security_group.dr_db.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}