#############################################################
# Project Information
#############################################################

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

#############################################################
# RDS MySQL Configuration
#############################################################

variable "engine" {
  description = "Database Engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "MySQL Engine Version"
  type        = string
  default     = "8.0.39"
}

variable "database_name" {
  description = "Database Name"
  type        = string
}

variable "master_username" {
  description = "Master Username"
  type        = string
}

variable "master_password" {
  description = "Master Password"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS Instance Class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial Storage (GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum Storage (GB)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage Type"
  type        = string
  default     = "gp3"
}

#############################################################
# Network
#############################################################

variable "vpc_id" {
  description = "Primary VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private Subnet IDs"
  type        = list(string)
}

#############################################################
# Security
#############################################################

variable "eks_security_group_id" {
  description = "EKS Security Group ID"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  type        = string
}

variable "database_security_group_id" {
  description = "Existing Database Security Group"
  type        = string
  default     = ""
}

#############################################################
# Backup
#############################################################

variable "backup_retention_period" {
  description = "Backup Retention Days"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Backup Window"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Maintenance Window"
  type        = string
  default     = "Sun:04:00-Sun:05:00"
}

#############################################################
# Database
#############################################################

variable "database_port" {
  description = "Database Port"
  type        = number
  default     = 3306
}

variable "parameter_group_family" {
  description = "MySQL Parameter Group Family"
  type        = string
  default     = "mysql8.0"
}

#############################################################
# Encryption
#############################################################

variable "kms_key_arn" {
  description = "KMS Key ARN"
  type        = string
}

#############################################################
# Monitoring
#############################################################

variable "monitoring_interval" {
  description = "Enhanced Monitoring Interval"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "Enhanced Monitoring IAM Role"
  type        = string
}

#############################################################
# Tags
#############################################################

variable "tags" {
  description = "Common Tags"
  type        = map(string)
  default     = {}
}