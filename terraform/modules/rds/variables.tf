#############################################################
# Project Information
#############################################################

variable "project_name" {

  description = "Project Name"

  type = string

}

variable "environment" {

  description = "Environment"

  type = string

}

#############################################################
# Aurora Configuration
#############################################################

variable "engine" {

  description = "Aurora Database Engine"

  type = string

  default = "aurora-mysql"

}

variable "engine_version" {

  description = "Aurora MySQL Engine Version"

  type = string

  default = "8.0.mysql_aurora.3.08.2"

}

variable "database_name" {

  description = "Database Name"

  type = string

}

variable "master_username" {

  description = "Master Username"

  type = string

}

variable "master_password" {

  description = "Master Password"

  type = string

  sensitive = true

}

#############################################################
# Network
#############################################################

variable "vpc_id" {

  description = "Primary VPC ID"

  type = string

}

variable "private_subnets" {

  description = "Private Subnet IDs"

  type = list(string)

}

#############################################################
# Security
#############################################################

variable "eks_security_group_id" {

  description = "EKS Security Group ID"

  type = string

}

variable "bastion_security_group_id" {

  description = "Bastion Security Group ID"

  type = string

}

#############################################################
# Backup
#############################################################

variable "backup_retention_period" {

  description = "Backup Retention"

  type = number

  default = 7

}

variable "preferred_backup_window" {

  description = "Backup Window"

  type = string

  default = "03:00-04:00"

}

#############################################################
# Monitoring
#############################################################

variable "monitoring_interval" {

  description = "Enhanced Monitoring"

  type = number

  default = 60

}

#############################################################
# Tags
#############################################################

variable "tags" {

  description = "Common Tags"

  type = map(string)

  default = {}

}

#############################################################
# Disaster Recovery Private Subnets
#############################################################

variable "dr_private_subnets" {

  description = "Private subnet IDs for the DR region"

  type = list(string)

  default = []

}

variable "database_security_group_id" {
  description = "Database Security Group ID"
  type        = string
}