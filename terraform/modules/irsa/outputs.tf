#############################################################
# Amazon EBS CSI Driver Role ARN
#############################################################

output "ebs_csi_driver_role_arn" {

  description = "Amazon EBS CSI Driver IAM Role ARN"

  value = aws_iam_role.ebs_csi_driver.arn

}

#############################################################
# Amazon EBS CSI Driver Role Name
#############################################################

output "ebs_csi_driver_role_name" {

  description = "Amazon EBS CSI Driver IAM Role Name"

  value = aws_iam_role.ebs_csi_driver.name

}

#############################################################
# Cluster Autoscaler Role ARN
#############################################################

output "cluster_autoscaler_role_arn" {

  description = "Cluster Autoscaler IAM Role ARN"

  value = aws_iam_role.cluster_autoscaler.arn

}

#############################################################
# Cluster Autoscaler Role Name
#############################################################

output "cluster_autoscaler_role_name" {

  description = "Cluster Autoscaler IAM Role Name"

  value = aws_iam_role.cluster_autoscaler.name

}

#############################################################
# Cluster Autoscaler Policy ARN
#############################################################

output "cluster_autoscaler_policy_arn" {

  description = "Cluster Autoscaler IAM Policy ARN"

  value = aws_iam_policy.cluster_autoscaler.arn

}

#############################################################
# AWS Load Balancer Controller Role ARN
#############################################################

output "aws_load_balancer_controller_role_arn" {

  description = "AWS Load Balancer Controller IAM Role ARN"

  value = aws_iam_role.aws_load_balancer_controller.arn

}

#############################################################
# AWS Load Balancer Controller Role Name
#############################################################

output "aws_load_balancer_controller_role_name" {

  description = "AWS Load Balancer Controller IAM Role Name"

  value = aws_iam_role.aws_load_balancer_controller.name

}

#############################################################
# AWS Load Balancer Controller Policy ARN
#############################################################

output "aws_load_balancer_controller_policy_arn" {

  description = "AWS Load Balancer Controller IAM Policy ARN"

  value = aws_iam_policy.aws_load_balancer_controller.arn

}