#############################################################
# General
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
# Regions
#############################################################

variable "primary_region" {
  description = "Primary Region"
  type        = string
}

variable "dr_region" {
  description = "DR Region"
  type        = string
}

#############################################################
# Bucket Names
#############################################################

variable "primary_bucket_name" {
  description = "Primary S3 Bucket Name"
  type        = string
}

variable "dr_bucket_name" {
  description = "DR S3 Bucket Name"
  type        = string
}

#############################################################
# Versioning
#############################################################

variable "versioning_enabled" {
  description = "Enable Versioning"
  type        = bool
  default     = true
}

#############################################################
# Encryption
#############################################################

variable "primary_kms_key_arn" {
  description = "Primary Region KMS Key ARN"
  type        = string
}

variable "dr_kms_key_arn" {
  description = "DR Region KMS Key ARN"
  type        = string
}

#############################################################
# Lifecycle
#############################################################

variable "enable_lifecycle" {
  description = "Enable Lifecycle Rules"
  type        = bool
  default     = true
}

variable "transition_days" {
  description = "Transition to IA Storage"
  type        = number
  default     = 30
}

variable "expiration_days" {
  description = "Delete Objects After"
  type        = number
  default     = 365
}

#############################################################
# Replication
#############################################################

variable "enable_replication" {
  description = "Enable Cross Region Replication"
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
# Replication
#############################################################

variable "replication_role_arn" {

  description = "IAM Role ARN for S3 Replication"

  type = string

}