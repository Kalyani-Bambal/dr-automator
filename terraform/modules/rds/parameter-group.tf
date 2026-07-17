#############################################################
# RDS MySQL Parameter Group
#############################################################

resource "aws_db_parameter_group" "primary" {

  provider = aws.primary

  name        = local.parameter_group_name
  family      = "mysql8.0"
  description = "RDS MySQL Parameter Group"

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
  # Logging
  ###########################################################

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  ###########################################################
  # Connections
  ###########################################################

  parameter {
    name  = "max_connections"
    value = "200"
  }

  ###########################################################
  # Time Zone
  ###########################################################

  parameter {
    name  = "time_zone"
    value = "UTC"
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.parameter_group_name
    }
  )
}