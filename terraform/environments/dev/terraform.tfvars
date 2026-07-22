project_name = "dr-automator"

environment = "dev"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

allowed_ssh_cidr = "103.197.75.203/32"

tags = {
  Project     = "DR"
  Environment = "dev"
  Owner       = "Kalyani"
  ManagedBy   = "Terraform"
}

#############################################################
# Multi Region
#############################################################

primary_region = "ap-south-1"

dr_region = "ap-southeast-1"

vpc_cidr_dr = "10.1.0.0/16"

public_subnet_cidrs_dr = [
  "10.1.1.0/24",
  "10.1.2.0/24"
]

private_subnet_cidrs_dr = [
  "10.1.11.0/24",
  "10.1.12.0/24"
]

availability_zones_dr = [
  "ap-southeast-1a",
  "ap-southeast-1b"
]

primary_azs = [

  "ap-south-1a",

  "ap-south-1b"

]

dr_azs = [

  "ap-southeast-1a",

  "ap-southeast-1b"

]

#############################################################
# Disaster Recovery
#############################################################

enable_disaster_recovery = false

dr_strategy = "pilot-light"

rto_minutes = 15

rpo_minutes = 5

#############################################################
# Aurora Database
#############################################################

database_name   = "drautomator"
master_username = "admin"
master_password = "Laptop#2026"

primary_ingress_hostname = "k8s-app-primary-xxxxxxxx.ap-south-1.elb.amazonaws.com"
primary_ingress_zone_id  = "ZP97RAFLXTNZK"

dr_ingress_hostname = "k8s-app-dr-yyyyyyyy.ap-southeast-1.elb.amazonaws.com"
dr_ingress_zone_id  = "Z1LMS91P8CMLE5"