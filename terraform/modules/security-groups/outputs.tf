############################################
# ALB Security Group
############################################

output "alb_security_group_id" {

  description = "ALB Security Group ID"

  value = aws_security_group.alb.id

}

############################################
# EKS Cluster Security Group
############################################

output "eks_cluster_security_group_id" {

  description = "EKS Cluster Security Group ID"

  value = aws_security_group.eks_cluster.id

}

############################################
# Worker Node Security Group
############################################

output "node_security_group_id" {

  description = "Worker Node Security Group ID"

  value = aws_security_group.node.id

}

############################################
# Database Security Group
############################################

output "database_security_group_id" {

  description = "Database Security Group ID"

  value = aws_security_group.database.id

}

############################################
# Bastion Security Group
############################################

output "bastion_security_group_id" {

  description = "Bastion Security Group ID"

  value = aws_security_group.bastion.id

}

