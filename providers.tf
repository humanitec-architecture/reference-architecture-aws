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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    humanitec = {
      source  = "humanitec/humanitec"
      version = "~> 1.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "humanitec" {
  org_id = var.humanitec_org_id
}

provider "github" {
  owner = var.github_org_id
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
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

provider "kubectl" {
  host                   = module.base.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.base.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.base.eks_cluster_name]
  }

  load_config_file = false
}
