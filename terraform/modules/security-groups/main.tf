############################################
# ALB Security Group
############################################

resource "aws_security_group" "alb" {

  name        = "${local.name_prefix}-alb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {

    description = "HTTP"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "HTTPS"

    from_port = 443

    to_port = 443

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-alb-sg"
    }
  )

}

############################################
# EKS Cluster Security Group
############################################

resource "aws_security_group" "eks_cluster" {

  name        = "${local.name_prefix}-eks-cluster-sg"
  description = "Security Group for EKS Control Plane"
  vpc_id      = var.vpc_id

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster-sg"
    }
  )

}

############################################
# Worker Node Security Group
############################################

resource "aws_security_group" "node" {

  name        = "${local.name_prefix}-node-sg"
  description = "Security Group for EKS Worker Nodes"
  vpc_id      = var.vpc_id

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-node-sg"
    }
  )

}

############################################
# Database Security Group
############################################

resource "aws_security_group" "database" {

  name        = "${local.name_prefix}-database-sg"
  description = "Security Group for MySQL/Aurora"
  vpc_id      = var.vpc_id

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-database-sg"
    }
  )

}

############################################
# Bastion Security Group
############################################

resource "aws_security_group" "bastion" {

  name        = "${local.name_prefix}-bastion-sg"
  description = "Security Group for Bastion Host"
  vpc_id      = var.vpc_id

  ingress {

    description = "SSH"

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = [var.allowed_ssh_cidr]

  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-bastion-sg"
    }
  )

}

############################################
# Security Group Rules
############################################

# ALB -> EKS Worker Nodes
resource "aws_security_group_rule" "alb_to_node" {

  type = "ingress"

  from_port = 80

  to_port = 80

  protocol = "tcp"

  security_group_id = aws_security_group.node.id

  source_security_group_id = aws_security_group.alb.id

}

resource "aws_security_group_rule" "alb_to_node_https" {

  type = "ingress"

  from_port = 443

  to_port = 443

  protocol = "tcp"

  security_group_id = aws_security_group.node.id

  source_security_group_id = aws_security_group.alb.id

}

# Worker Nodes -> EKS Control Plane
resource "aws_security_group_rule" "node_to_cluster" {

  type = "ingress"

  from_port = 443

  to_port = 443

  protocol = "tcp"

  security_group_id = aws_security_group.eks_cluster.id

  source_security_group_id = aws_security_group.node.id

}

# Worker Nodes -> Database
resource "aws_security_group_rule" "node_to_database" {

  type = "ingress"

  from_port = 3306

  to_port = 3306

  protocol = "tcp"

  security_group_id = aws_security_group.database.id

  source_security_group_id = aws_security_group.node.id

}

# Bastion -> Database
resource "aws_security_group_rule" "bastion_to_database" {

  type = "ingress"

  from_port = 3306

  to_port = 3306

  protocol = "tcp"

  security_group_id = aws_security_group.database.id

  source_security_group_id = aws_security_group.bastion.id

}

# Worker Nodes communicate with each other
resource "aws_security_group_rule" "node_self" {

  type = "ingress"

  from_port = 0

  to_port = 65535

  protocol = "-1"

  security_group_id = aws_security_group.node.id

  self = true

}



########################################################
# SSH Access & Bastion Outbound
#
# The bastion security group already defines the SSH ingress and
# the all-outbound egress rules inline above. Removed separate
# `aws_vpc_security_group_ingress_rule` and
# `aws_vpc_security_group_egress_rule` resources to avoid
# creating duplicate rules in AWS (which causes
# InvalidPermission.Duplicate errors).
########################################################