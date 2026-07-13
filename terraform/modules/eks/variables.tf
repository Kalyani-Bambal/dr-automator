###################################################
# Project
###################################################

variable "project_name" {

  description = "Project Name"

  type = string

}

variable "environment" {

  description = "Environment"

  type = string

}

###################################################
# Cluster
###################################################

variable "cluster_name" {

  description = "EKS Cluster Name"

  type = string

}

variable "cluster_version" {

  description = "Kubernetes Version"

  type = string

  default = "1.33"

}

###################################################
# Networking
###################################################

variable "vpc_id" {

  description = "VPC ID"

  type = string

}

variable "private_subnets" {

  description = "Private Subnets"

  type = list(string)

}

###################################################
# IAM
###################################################

variable "cluster_role_arn" {

  description = "EKS Cluster Role ARN"

  type = string

}

variable "node_role_arn" {

  description = "Worker Node IAM Role ARN"

  type = string

}

###################################################
# Security Groups
###################################################

variable "cluster_security_group_id" {

  description = "Cluster Security Group"

  type = string

}

variable "node_security_group_id" {

  description = "Worker Node Security Group"

  type = string

}

###################################################
# Node Group
###################################################

variable "instance_types" {

  description = "EC2 Instance Types"

  type = list(string)

  default = [

    "t3.micro"

  ]

}

variable "capacity_type" {

  description = "ON_DEMAND or SPOT"

  type = string

  default = "ON_DEMAND"

}

variable "desired_size" {

  type = number

  default = 2

}

variable "min_size" {

  type = number

  default = 2

}

variable "max_size" {

  type = number

  default = 4

}

variable "disk_size" {

  type = number

  default = 30

}

###################################################
# Logging
###################################################

variable "enabled_cluster_log_types" {

  type = list(string)

  default = [

    "api",

    "audit",

    "authenticator",

    "controllerManager",

    "scheduler"

  ]

}

###################################################
# Tags
###################################################

variable "tags" {

  type = map(string)

  default = {}

}

variable "public_access_cidrs" {

  description = "CIDR blocks allowed to access the EKS API endpoint"

  type = list(string)

  default = [
    "0.0.0.0/0"
  ]

}

###################################################
# CloudWatch
###################################################

variable "log_retention_in_days" {

  description = "CloudWatch Log Retention"

  type = number

  default = 30

}

variable "kms_key_arn" {
  description = "KMS Key ARN"
  type        = string
}

###################################################
# IRSA Role for Amazon EBS CSI Driver
###################################################

variable "ebs_csi_role_arn" {

  description = "IAM Role ARN for the Amazon EBS CSI Driver"

  type = string

  default = null

}