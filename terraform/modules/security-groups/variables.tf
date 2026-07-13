########################################
# Project Information
########################################

variable "project_name" {

  description = "Project Name"

  type = string

}

variable "environment" {

  description = "Environment Name"

  type = string

}

########################################
# Networking
########################################

variable "vpc_id" {

  description = "VPC ID"

  type = string

}

########################################
# Bastion SSH Access
########################################

variable "allowed_ssh_cidr" {

  description = "CIDR allowed to SSH to Bastion"

  type = string

}

########################################
# Tags
########################################

variable "tags" {

  description = "Common Tags"

  type = map(string)

  default = {}

}