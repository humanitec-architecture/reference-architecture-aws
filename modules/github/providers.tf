terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.38"
    }
  }
  required_version = ">= 1.3.0"
}
