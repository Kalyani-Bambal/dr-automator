#############################
# Project Details
#############################

variable "project_name" {

  description = "Project Name"

  type = string

}

variable "environment" {

  description = "Environment"

  type = string

}

#############################
# Networking
#############################

variable "vpc_cidr" {

  description = "VPC CIDR Block"

  type = string

}

variable "public_subnet_cidrs" {

  description = "Public Subnet CIDRs"

  type = list(string)

}

variable "private_subnet_cidrs" {

  description = "Private Subnet CIDRs"

  type = list(string)

}

#############################
# Availability Zones
#############################

variable "availability_zones" {

  description = "Availability Zones"

  type = list(string)

}

#############################
# NAT Gateway
#############################

variable "enable_nat_gateway" {

  description = "Create NAT Gateway"

  type = bool

  default = true

}

#############################
# Tags
#############################

variable "tags" {

  description = "Common Tags"

  type = map(string)

  default = {}

}