
locals {
  res_def_prefix = "default-"
}

# Configure default resources for example apps


locals {
  ingress_address = data.kubernetes_service.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname
}

data "aws_elb_hosted_zone_id" "main" {}

# k8s-cluster

resource "humanitec_resource_account" "cluster_account" {
  id   = var.cluster_name
  name = var.cluster_name
  type = "aws-role"

  credentials = jsonencode({
    aws_role    = aws_iam_role.humanitec_svc.arn
    external_id = random_password.external_id.result
  })

  depends_on = [aws_iam_role_policy_attachment.humanitec_svc]
}

resource "humanitec_resource_definition" "k8s_cluster_driver" {
  driver_type = "humanitec/k8s-cluster-eks"
  id          = var.cluster_name
  name        = var.cluster_name
  type        = "k8s-cluster"

  driver_account = humanitec_resource_account.cluster_account.id
  driver_inputs = {
    values_string = jsonencode({
      "name"                     = module.aws_eks.cluster_name
      "loadbalancer"             = local.ingress_address
      "loadbalancer_hosted_zone" = data.aws_elb_hosted_zone_id.main.id
      "region"                   = var.region
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_cluster_driver" {
  resource_definition_id = humanitec_resource_definition.k8s_cluster_driver.id
  env_type               = var.environment
}

# k8s-namespace

resource "humanitec_resource_definition" "k8s_namespace" {
  driver_type = "humanitec/echo"
  id          = "default-namespace"
  name        = "default-namespace"
  type        = "k8s-namespace"

  driver_inputs = {
    values_string = jsonencode({
      "namespace" = "$${context.app.id}-$${context.env.id}"
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_namespace" {
  resource_definition_id = humanitec_resource_definition.k8s_namespace.id
}


# in-cluster postgres

module "default_postgres" {
  source = "github.com/humanitec-architecture/resource-packs-in-cluster?ref=v2024-06-05//humanitec-resource-defs/postgres/basic"

  prefix = local.res_def_prefix
}

resource "humanitec_resource_definition_criteria" "default_postgres" {
  resource_definition_id = module.default_postgres.id
  env_type               = var.environment
}

module "default_mysql" {
  source = "github.com/humanitec-architecture/resource-packs-in-cluster?ref=v2024-06-05//humanitec-resource-defs/mysql/basic"

  prefix = local.res_def_prefix
}

resource "humanitec_resource_definition_criteria" "default_mysql" {
  resource_definition_id = module.default_mysql.id
  env_type               = var.environment
}

resource "humanitec_resource_definition" "emptydir_volume" {
  driver_type = "humanitec/template"
  id          = "volume-emptydir"
  name        = "volume-emptydir"
  type        = "volume"
  driver_inputs = {
    values_string = jsonencode({
      "templates" = {
        "manifests" = {
          "emptydir.yaml" = {
            "location" = "volumes"
            "data"     = <<END_OF_TEXT
name: $${context.res.guresid}-emptydir
emptyDir:
  sizeLimit: 1024Mi
END_OF_TEXT
          }
        }
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "emptydir_volume" {
  resource_definition_id = humanitec_resource_definition.emptydir_volume.id
  env_type               = var.environment

  force_delete = true
}
