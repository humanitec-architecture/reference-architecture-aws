locals {
  admin_policy_arn   = "arn:aws:iam::aws:policy/AdministratorAccess"
  humanitec_user_arn = "arn:aws:iam::767398028804:user/humanitec"
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

resource "random_password" "external_id" {
  length  = 16
  special = false
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.humanitec_user_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [random_password.external_id.result]
    }
  }
}


# User for Humanitec to access the EKS cluster
resource "aws_iam_role" "humanitec_svc" {
  name = var.iam_role_name

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "humanitec_svc" {
  role       = aws_iam_role.humanitec_svc.name
  policy_arn = local.admin_policy_arn
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

locals {
  default_k8s_access_entries = [
    {
      id            = aws_iam_role.humanitec_svc.name
      principal_arn = aws_iam_role.humanitec_svc.arn
      groups        = ["system:masters"]
    }
  ]
  k8s_access_entries = concat(local.default_k8s_access_entries, var.additional_k8s_access_entries)
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
  version = "~> 20.2"

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

      disk_size                  = var.disk_size
      use_custom_launch_template = false
    }
  }

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    for s in local.k8s_access_entries : s.id => {
      kubernetes_groups = []
      principal_arn     = s.principal_arn

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
  }

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
  version = "4.12.1"
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

  set {
    name  = "controller.containerSecurityContext.runAsUser"
    value = 101
  }

  set {
    name  = "controller.containerSecurityContext.runAsGroup"
    value = 101
  }

  set {
    name  = "controller.containerSecurityContext.allowPrivilegeEscalation"
    value = false
  }

  set {
    name  = "controller.containerSecurityContext.readOnlyRootFilesystem"
    value = false
  }

  set {
    name  = "controller.containerSecurityContext.runAsNonRoot"
    value = true
  }

  set_list {
    name  = "controller.containerSecurityContext.capabilities.drop"
    value = ["ALL"]
  }

  set_list {
    name  = "controller.containerSecurityContext.capabilities.add"
    value = ["NET_BIND_SERVICE"]
  }

  depends_on = [module.aws_eks.eks_managed_node_groups]
}
