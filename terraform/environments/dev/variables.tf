variable "project_name" {

  type = string

}

variable "environment" {

  type = string

}

variable "vpc_cidr" {

  type = string

}

variable "public_subnet_cidrs" {

  type = list(string)

}

variable "private_subnet_cidrs" {

  type = list(string)

}

variable "availability_zones" {

  type = list(string)

}

variable "tags" {

  type = map(string)

}

variable "allowed_ssh_cidr" {

  description = "Office Public IP"

  type = string

}

variable "primary_region" {

  description = "Primary AWS Region for this environment"

  type = string

}

variable "dr_region" {

  description = "Disaster Recovery AWS Region for this environment"

  type = string

}

variable "primary_azs" {

  description = "Availability zones for primary region"

  type = list(string)

}

variable "dr_azs" {

  description = "Availability zones for disaster recovery region"

  type = list(string)

}

variable "enable_disaster_recovery" {

  description = "Enable disaster recovery resources"

  type = bool

  default = false

}

variable "dr_strategy" {

  description = "Disaster recovery strategy"

  type = string

  default = "pilot-light"

}

variable "rto_minutes" {

  description = "Recovery time objective in minutes"

  type = number

  default = 15

}

variable "rpo_minutes" {

  description = "Recovery point objective in minutes"

  type = number

  default = 5

}

#############################################################
# DR Networking
#############################################################

variable "vpc_cidr_dr" {

  description = "VPC CIDR for DR region"

  type = string

}

variable "public_subnet_cidrs_dr" {

  description = "Public Subnet CIDRs for DR region"

  type = list(string)

}

variable "private_subnet_cidrs_dr" {

  description = "Private Subnet CIDRs for DR region"

  type = list(string)

}

variable "availability_zones_dr" {

  description = "Availability Zones for DR region"

  type = list(string)

}

variable "database_name" {
  description = "Aurora database name"
  type        = string
}

variable "master_username" {
  description = "Aurora master username"
  type        = string
}

variable "master_password" {
  description = "Aurora master password"
  type        = string
  sensitive   = true
}

#############################################################
# Primary ALB
#############################################################

variable "primary_ingress_hostname" {
  type = string
}

variable "primary_ingress_zone_id" {
  type = string
}
#############################################################
# Route53
#############################################################

variable "hosted_zone_name" {
  description = "Public Hosted Zone Name"
  type        = string
  default     = ""
}

variable "create_hosted_zone" {
  description = "Create Hosted Zone"
  type        = bool
  default     = false
} #############################################################
# DR ALB
#############################################################

variable "dr_ingress_hostname" {
  type = string
}

variable "dr_ingress_zone_id" {
  type = string
}