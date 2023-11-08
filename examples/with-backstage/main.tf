# AWS reference architecture

module "base" {
  source = "../../modules/base"

  region = var.aws_region
  instance_types = var.instance_types
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
