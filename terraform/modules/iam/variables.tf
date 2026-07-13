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
# EKS
###################################################

variable "cluster_name" {

  description = "EKS Cluster Name"

  type = string

}

###################################################
# IRSA
###################################################

variable "oidc_provider_arn" {

  description = "OIDC Provider ARN"

  type = string

  default = ""

}

###################################################
# Tags
###################################################

variable "tags" {

  description = "Common Tags"

  type = map(string)

  default = {}

}