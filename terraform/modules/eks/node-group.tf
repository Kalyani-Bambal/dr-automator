#############################################################
# EKS Launch Template
#############################################################

resource "aws_launch_template" "eks" {

  name_prefix = "${local.name_prefix}-eks-node-"

  description = "Launch Template for EKS Managed Node Group"

  update_default_version = true

  #############################################################
  # Root Volume
  #############################################################

  block_device_mappings {

    device_name = "/dev/xvda"

    ebs {

      volume_size = var.disk_size

      volume_type = "gp3"

      encrypted = true

      delete_on_termination = true

    }

  }

  #############################################################
  # Metadata Options
  #############################################################

  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

    http_put_response_hop_limit = 2

    instance_metadata_tags = "enabled"

  }

  #############################################################
  # Monitoring
  #############################################################

  monitoring {

    enabled = true

  }

  #############################################################
  # Instance Tags
  #############################################################

  tag_specifications {

    resource_type = "instance"

    tags = merge(

      local.common_tags,

      {

        Name = "${local.name_prefix}-eks-node"

        Resource = "EKS Worker Node"

      }

    )

  }

  #############################################################
  # Volume Tags
  #############################################################

  tag_specifications {

    resource_type = "volume"

    tags = merge(

      local.common_tags,

      {

        Name = "${local.name_prefix}-eks-volume"

        Resource = "EKS Root Volume"

      }

    )

  }

  #############################################################
  # Launch Template Tags
  #############################################################

  tags = merge(

    local.common_tags,

    {

      Name = "${local.name_prefix}-launch-template"

      Resource = "Launch Template"

    }

  )

  #############################################################
  # Lifecycle
  #############################################################

  lifecycle {

    create_before_destroy = true

  }

}

#############################################################
# EKS Managed Node Group
#############################################################

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnets
  capacity_type   = var.capacity_type
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    environment = var.environment
    project     = var.project_name
    workload    = "general"
  }

  launch_template {
    id      = aws_launch_template.eks.id
    version = aws_launch_template.eks.latest_version
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_launch_template.eks,
  ]

  tags = merge(
    local.common_tags,
    {
      Name     = "${local.name_prefix}-node-group"
      Resource = "EKS Managed Node Group"
    }
  )
}