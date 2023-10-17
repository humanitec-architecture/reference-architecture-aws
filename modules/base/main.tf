locals {
  admin_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# User for Humanitec to access the EKS cluster

resource "aws_iam_user" "humanitec_svc" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy_attachment" "humanitec_svc" {
  user       = aws_iam_user.humanitec_svc.name
  policy_arn = local.admin_policy_arn
}

resource "aws_iam_access_key" "humanitec_svc" {
  user = aws_iam_user.humanitec_svc.name

  # Ensure that the policy is not deleted before the access key
  depends_on = [aws_iam_user_policy_attachment.humanitec_svc]
}

# VPC and EKS cluster

data "aws_region" "current" {}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs             = formatlist("${data.aws_region.current.name}%s", ["a", "b", "c"])
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true

  tags = local.tags
}

data "aws_caller_identity" "current" {}

locals {
  default_aws_auth_users = [
    {
      userarn  = data.aws_caller_identity.current.arn
      username = "creator"
      groups   = ["system:masters"]
    },
    {
      userarn  = aws_iam_user.humanitec_svc.arn
      username = aws_iam_user.humanitec_svc.name
      groups   = ["system:masters"]
    }
  ]
  aws_auth_users = concat(local.default_aws_auth_users, var.additional_aws_auth_users)
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.aws_eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

module "aws_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  vpc_id     = module.aws_vpc.vpc_id
  subnet_ids = module.aws_vpc.private_subnets

  eks_managed_node_groups = {
    green = {
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      instance_types = var.instance_types
      capacity_type  = var.capacity_type
    }
  }

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_users            = local.aws_auth_users

  # required for ingress-nginx see https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2513
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  tags = local.tags
}


# Ingress controller

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"

  chart   = "ingress-nginx"
  version = "4.8.2"
  wait    = true
  timeout = 600

  set {
    type  = "string"
    name  = "controller.replicaCount"
    value = var.ingress_nginx_replica_count
  }

  set {
    type  = "string"
    name  = "controller.minAvailable"
    value = var.ingress_nginx_min_unavailable
  }

  depends_on = [module.aws_eks.eks_managed_node_groups]
}
