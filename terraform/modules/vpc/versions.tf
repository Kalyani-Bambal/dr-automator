terraform {

  required_version = ">= 1.8.0"

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      configuration_aliases = [
        aws.primary,
        aws.dr
      ]

      version = "~> 5.0"

    }

  }

}