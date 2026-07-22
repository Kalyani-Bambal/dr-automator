#############################################################
# General
#############################################################

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

#############################################################
# Regions
#############################################################

variable "primary_region" {
  description = "Primary AWS Region"
  type        = string
}

variable "dr_region" {
  description = "Disaster Recovery Region"
  type        = string
}

#############################################################
# Networking
#############################################################

variable "vpc_id" {
  description = "Primary VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Primary Private Subnets"
  type        = list(string)
}

variable "dr_vpc_id" {
  description = "DR VPC ID"
  type        = string
}

variable "dr_private_subnets" {
  description = "DR Private Subnets"
  type        = list(string)
}

#############################################################
# Security Groups
#############################################################

variable "eks_security_group_id" {
  description = "EKS Security Group"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Bastion Security Group"
  type        = string
}

variable "dr_eks_security_group_id" {
  description = "DR EKS Security Group"
  type        = string
  default     = ""
}

variable "dr_bastion_security_group_id" {
  description = "DR Bastion Security Group"
  type        = string
  default     = ""
}

#############################################################
# Database Configuration
#############################################################

variable "db_name" {
  description = "Database Name"
  type        = string
  default     = "drautomator"
}

variable "db_username" {
  description = "Master Username"
  type        = string
}

variable "db_password" {
  description = "Master Password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "MySQL Port"
  type        = number
  default     = 3306
}

variable "engine_version" {
  description = "MySQL Engine Version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS Instance Type"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage Size"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum Storage"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage Type"
  type        = string
  default     = "gp3"
}

#############################################################
# Backup
#############################################################

variable "backup_retention_period" {
  description = "Backup Retention"
  type        = number
  default     = 0
}

variable "backup_window" {
  description = "Backup Window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance Window"
  type        = string
  default     = "Sun:05:00-Sun:06:00"
}

#############################################################
# Monitoring
#############################################################

variable "monitoring_interval" {
  description = "Enhanced Monitoring"
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

#############################################################
# Encryption
#############################################################

variable "kms_key_arn" {
  description = "KMS Key ARN"
  type        = string
}

#############################################################
# Snapshot Copy
#############################################################

variable "copy_tags_to_snapshot" {
  description = "Copy Tags to Snapshot"
  type        = bool
  default     = true
}

#############################################################
# Tags
#############################################################

variable "tags" {
  description = "Common Tags"
  type        = map(string)
  default     = {}
}

#############################################################
# Database Security Group
#############################################################

variable "db_security_group_id" {
  description = "Primary Database Security Group ID"
  type        = string
}

#############################################################
# Snapshot
#############################################################

variable "create_manual_snapshot" {

  description = "Create manual snapshot"

  type = bool

  default = true
}

#############################################################
# DR Restore
#############################################################

variable "enable_dr_restore" {
  description = "Restore database in DR region"
  type        = bool
  default     = false
}

variable "dr_instance_class" {
  description = "DR RDS Instance Class"
  type        = string
  default     = "db.t3.micro"
}

variable "dr_db_security_group_id" {
  description = "DR Database Security Group ID"
  type        = string
}