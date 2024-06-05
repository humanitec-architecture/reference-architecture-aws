
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    humanitec = {
      source  = "humanitec/humanitec"
      version = "~> 1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
  required_version = ">= 1.3.0"
}

provider "humanitec" {
  org_id = var.humanitec_org_id
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}


module "base" {
  source = "./modules/base"

  region         = var.aws_region
  instance_types = var.instance_types
  disk_size      = var.disk_size
}

provider "kubernetes" {
  host                   = module.base.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.base.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.base.eks_cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.base.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.base.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.base.eks_cluster_name]
    }
  }
}
