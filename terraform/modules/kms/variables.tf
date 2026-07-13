#########################################################
# Project Information
#########################################################

variable "project_name" {

  description = "Project name"

  type = string

}

variable "environment" {

  description = "Environment"

  type = string

}

#########################################################
# KMS Key
#########################################################

variable "kms_key_description" {

  description = "Description for KMS Key"

  type = string

  default = "KMS Key for EKS and RDS Encryption"

}

variable "enable_key_rotation" {

  description = "Enable automatic key rotation"

  type = bool

  default = true

}

variable "deletion_window_in_days" {

  description = "Deletion window"

  type = number

  default = 30

}

#########################################################
# Multi Region Key
#########################################################

variable "multi_region" {

  description = "Create Multi Region Key"

  type = bool

  default = false

}

#########################################################
# Tags
#########################################################

variable "tags" {

  description = "Common Tags"

  type = map(string)

  default = {}

}