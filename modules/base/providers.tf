terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.50"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }
    helm = {
      source = "hashicorp/helm"
    }
    humanitec = {
      source = "humanitec/humanitec"
    }
  }
  required_version = ">= 1.3.0"
}
