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

}

variable "dr_region" {

  description = "Disaster Recovery AWS Region"

  type = string

}

#############################################################
# Route53
#############################################################

variable "hosted_zone_name" {

  description = "Public Hosted Zone Name"

  type = string

}

variable "create_hosted_zone" {

  description = "Create Hosted Zone"

  type = bool

  default = false

}

#############################################################
# Primary Ingress ALB
#############################################################

variable "primary_ingress_hostname" {

  description = "Hostname of the Primary ALB created by AWS Load Balancer Controller"

  type = string

}

variable "primary_ingress_zone_id" {

  description = "Hosted Zone ID of the Primary ALB"

  type = string

}

#############################################################
# DR Ingress ALB
#############################################################

variable "dr_ingress_hostname" {

  description = "Hostname of the DR ALB created by AWS Load Balancer Controller"

  type = string

}

variable "dr_ingress_zone_id" {

  description = "Hosted Zone ID of the DR ALB"

  type = string

}

#############################################################
# Health Check
#############################################################

variable "health_check_path" {

  description = "Application Health Check Path"

  type = string

  default = "/health"

}

variable "health_check_port" {

  description = "Health Check Port"

  type = number

  default = 80

}

variable "health_check_protocol" {

  description = "Health Check Protocol"

  type = string

  default = "HTTPS"

}

variable "failure_threshold" {

  description = "Failure Threshold"

  type = number

  default = 3

}

variable "request_interval" {

  description = "Health Check Interval"

  type = number

  default = 30

}

#############################################################
# Common Tags
#############################################################

variable "tags" {

  description = "Common Tags"

  type = map(string)

  default = {}

}