############################################################
# EKS Cluster Role Name
############################################################

output "eks_cluster_role_name" {

  description = "EKS Cluster IAM Role Name"

  value = aws_iam_role.eks_cluster.name

}

############################################################
# EKS Cluster Role ARN
############################################################

output "eks_cluster_role_arn" {

  description = "EKS Cluster IAM Role ARN"

  value = aws_iam_role.eks_cluster.arn

}

############################################################
# Worker Node Role Name
############################################################

output "node_group_role_name" {

  description = "Worker Node IAM Role Name"

  value = aws_iam_role.node_group.name

}

############################################################
# Worker Node Role ARN
############################################################

output "node_group_role_arn" {

  description = "Worker Node IAM Role ARN"

  value = aws_iam_role.node_group.arn

}

############################################################
# Instance Profile
############################################################

output "node_instance_profile_name" {

  description = "EC2 Instance Profile Name"

  value = aws_iam_instance_profile.node_group.name

}

############################################################
# ECR Policy ARN
############################################################

output "ecr_access_policy_arn" {

  description = "Amazon ECR Access Policy ARN"

  value = aws_iam_policy.ecr_access.arn

}

############################################################
# CloudWatch Policy ARN
############################################################

output "cloudwatch_access_policy_arn" {

  description = "CloudWatch Access Policy ARN"

  value = aws_iam_policy.cloudwatch_access.arn

}

############################################################
# RDS Monitoring Role ARN
############################################################

output "rds_monitoring_role_arn" {

  description = "RDS Enhanced Monitoring Role ARN"

  value = aws_iam_role.rds_monitoring.arn

}

#############################################################
# S3 Replication Role
#############################################################

output "s3_replication_role_arn" {

  value = aws_iam_role.s3_replication.arn

}