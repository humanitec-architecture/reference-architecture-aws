terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }
    humanitec = {
      source  = "humanitec/humanitec"
      version = "~> 1.0"
    }
  }
  required_version = ">= 1.3.0"
}
