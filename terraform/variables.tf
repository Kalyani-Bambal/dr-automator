# variable "region" {
#   type = string
# }

# variable "bucket_name" {
#   type = string
# }

# variable "dynamodb_table" {
#   type = string
# }

# variable "environment" {
#   type = string
# }

#############################################################
# Project
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
# AWS Regions
#############################################################

variable "primary_region" {

  description = "Primary AWS Region"

  type = string

  default = "ap-south-1"

}

variable "dr_region" {

  description = "Disaster Recovery AWS Region"

  type = string

  default = "ap-southeast-1"

}

#############################################################
# Availability Zones
#############################################################

variable "primary_azs" {

  description = "Availability Zones for Primary Region"

  type = list(string)

  default = [

    "ap-south-1a",

    "ap-south-1b"

  ]

}

variable "dr_azs" {

  description = "Availability Zones for DR Region"

  type = list(string)

  default = [

    "ap-southeast-1a",

    "ap-southeast-1b"

  ]

}

#############################################################
# Tags
#############################################################

variable "tags" {

  description = "Common Resource Tags"

  type = map(string)

  default = {

    ManagedBy = "Terraform"

  }

}

#############################################################
# Disaster Recovery
#############################################################

variable "enable_disaster_recovery" {

  description = "Deploy Disaster Recovery Infrastructure"

  type = bool

  default = false

}

variable "dr_strategy" {

  description = "Disaster Recovery Strategy"

  type = string

  default = "pilot-light"

}

variable "rto_minutes" {

  description = "Recovery Time Objective"

  type = number

  default = 15

}

variable "rpo_minutes" {

  description = "Recovery Point Objective"

  type = number

  default = 5

}