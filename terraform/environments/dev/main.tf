module "vpc" {

  source = "../../modules/vpc"

  providers = {
    aws         = aws.primary
    aws.primary = aws.primary
    aws.dr      = aws.dr
  }

  project_name = var.project_name

  environment = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnet_cidrs = var.public_subnet_cidrs

  private_subnet_cidrs = var.private_subnet_cidrs

  availability_zones = var.availability_zones

  enable_nat_gateway = true

  tags = var.tags

}

####################################################
# Security Group Module
####################################################

module "security_groups" {

  source = "../../modules/security-groups"

  providers = {
    aws = aws.primary
  }

  project_name = var.project_name

  environment = var.environment

  vpc_id = module.vpc.vpc_id

  allowed_ssh_cidr = var.allowed_ssh_cidr

  tags = var.tags

}

#############################################################
# KMS Module
#############################################################

module "kms" {

  source = "../../modules/kms"

  providers = {
    aws = aws.primary
  }

  project_name = var.project_name

  environment = var.environment

  kms_key_description = "KMS Key for DR Automator"

  enable_key_rotation = true

  deletion_window_in_days = 30

  multi_region = false

  tags = var.tags

}

module "iam" {

  source = "../../modules/iam"

  providers = {
    aws = aws.primary
  }

  project_name = var.project_name

  environment = var.environment

  cluster_name = "dr-automator-dev-eks"

  tags = var.tags

}

module "eks" {

  source = "../../modules/eks"

  providers = {
    aws = aws.primary
  }

  project_name = var.project_name

  environment = var.environment

  cluster_name = "dr-automator-dev-eks"

  cluster_version = "1.33"

  vpc_id = module.vpc.vpc_id

  private_subnets = module.vpc.private_subnets

  cluster_role_arn = module.iam.eks_cluster_role_arn

  node_role_arn = module.iam.node_group_role_arn

  cluster_security_group_id = module.security_groups.eks_cluster_security_group_id

  node_security_group_id = module.security_groups.node_security_group_id

  kms_key_arn = module.kms.kms_key_arn

  public_access_cidrs = [

    "0.0.0.0/0"

  ]

  instance_types = ["c7i-flex.large"]

  capacity_type = "ON_DEMAND"

  desired_size = 3

  min_size = 2

  max_size = 4

  disk_size = 30

  ebs_csi_role_arn = module.irsa_dr.ebs_csi_driver_role_arn

  tags = var.tags

}

module "irsa" {

  source = "../../modules/irsa"

  providers = {
    aws = aws.primary
  }

  project_name = var.project_name

  environment = var.environment

  oidc_provider_arn = module.eks.oidc_provider_arn

  oidc_provider_url = module.eks.oidc_provider_url

  namespace = "kube-system"

  service_account_name = "ebs-csi-controller-sa"

  role_name = "ebs-csi-driver-role"

  tags = var.tags

}

#############################################################
# Disaster Recovery VPC
#############################################################

module "vpc_dr" {

  source = "../../modules/vpc"

  providers = {
    aws         = aws.dr
    aws.primary = aws.dr
    aws.dr      = aws.dr
  }

  project_name = var.project_name

  environment = "${var.environment}-dr"

  vpc_cidr = var.vpc_cidr_dr

  public_subnet_cidrs = var.public_subnet_cidrs_dr

  private_subnet_cidrs = var.private_subnet_cidrs_dr

  availability_zones = var.availability_zones_dr

  enable_nat_gateway = true

  tags = var.tags

}

#############################################################
# Disaster Recovery Security Groups
#############################################################

module "security_groups_dr" {

  source = "../../modules/security-groups"

  providers = {
    aws = aws.dr
  }

  project_name = var.project_name

  environment = "${var.environment}-dr"

  vpc_id = module.vpc_dr.vpc_id

  allowed_ssh_cidr = var.allowed_ssh_cidr

  tags = var.tags

}

#############################################################
# Disaster Recovery IAM
#############################################################

module "iam_dr" {

  source = "../../modules/iam"

  providers = {
    aws = aws.dr
  }

  project_name = var.project_name

  environment = "${var.environment}-dr"

  cluster_name = "dr-automator-dr-eks"

  tags = var.tags

}

#############################################################
# Disaster Recovery KMS
#############################################################

module "kms_dr" {

  source = "../../modules/kms"

  providers = {
    aws = aws.dr
  }

  project_name = var.project_name

  environment = "${var.environment}-dr"

  tags = var.tags

}

#############################################################
# Disaster Recovery EKS
#############################################################

module "eks_dr" {

  source = "../../modules/eks"

  providers = {
    aws = aws.dr
  }

  project_name = var.project_name

  environment = "${var.environment}-dr"

  cluster_name = "${local.name_prefix}-dr-eks"

  cluster_version = "1.33"

  vpc_id = module.vpc_dr.vpc_id

  private_subnets = module.vpc_dr.private_subnets

  cluster_role_arn = module.iam_dr.eks_cluster_role_arn

  node_role_arn = module.iam_dr.node_group_role_arn

  cluster_security_group_id = module.security_groups_dr.eks_cluster_security_group_id

  node_security_group_id = module.security_groups_dr.node_security_group_id

  kms_key_arn = module.kms_dr.kms_key_arn

  ebs_csi_role_arn = module.irsa_dr.ebs_csi_driver_role_arn

  desired_size = 2

  min_size = 2

  max_size = 4

  instance_types = ["c7i-flex.large"]

  capacity_type = "ON_DEMAND"

  disk_size = 30

  public_access_cidrs = ["0.0.0.0/0"]

  tags = var.tags

}

#############################################################
# Disaster Recovery IRSA
#############################################################

module "irsa_dr" {

  source = "../../modules/irsa"

  providers = {
    aws = aws.dr
  }

  project_name = var.project_name

  environment = "${var.environment}-dr"

  oidc_provider_arn = module.eks_dr.oidc_provider_arn

  oidc_provider_url = module.eks_dr.oidc_provider_url

  namespace = "kube-system"

  service_account_name = "ebs-csi-controller-sa"

  role_name = "${local.name_prefix}-dr-irsa"

  tags = var.tags

}