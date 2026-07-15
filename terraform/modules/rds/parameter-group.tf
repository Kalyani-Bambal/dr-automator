#############################################################
# MySQL DB Parameter Group
#############################################################

resource "aws_db_parameter_group" "database" {

  provider = aws.primary

  name        = local.parameter_group_name
  family      = var.parameter_group_family
  description = "MySQL 8.0 Parameter Group"

  ###########################################################
  # Character Set
  ###########################################################

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  ###########################################################
  # Connections
  ###########################################################

  parameter {
    name  = "max_connections"
    value = "500"
  }

  parameter {
    name  = "connect_timeout"
    value = "10"
  }

  parameter {
    name  = "wait_timeout"
    value = "28800"
  }

  parameter {
    name  = "interactive_timeout"
    value = "28800"
  }

  ###########################################################
  # Slow Query Log
  ###########################################################

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  ###########################################################
  # General Log
  ###########################################################

  parameter {
    name  = "general_log"
    value = "0"
  }

  ###########################################################
  # Time Zone
  ###########################################################

  parameter {
    name  = "time_zone"
    value = "UTC"
  }

  ###########################################################
  # Tags
  ###########################################################

  tags = merge(
    local.common_tags,
    {
      Name = local.parameter_group_name
    }
  )

}