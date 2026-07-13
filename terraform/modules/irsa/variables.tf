#########################################################
# Project Information
#########################################################

variable "project_name" {

  description = "Project Name"

  type = string

}

variable "environment" {

  description = "Environment"

  type = string

}

#########################################################
# OIDC
#########################################################

variable "oidc_provider_arn" {

  description = "OIDC Provider ARN"

  type = string

}

variable "oidc_provider_url" {

  description = "OIDC Provider URL"

  type = string

}

#########################################################
# Kubernetes Service Account
#########################################################

variable "namespace" {

  description = "Kubernetes Namespace"

  type = string

}

variable "service_account_name" {

  description = "Kubernetes Service Account"

  type = string

}

#########################################################
# IAM Role
#########################################################

variable "role_name" {

  description = "IAM Role Name"

  type = string

}

#########################################################
# Tags
#########################################################

variable "tags" {

  description = "Common Tags"

  type = map(string)

  default = {}

}