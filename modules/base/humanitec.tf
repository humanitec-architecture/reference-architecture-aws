# Humanitec resource definition to connect the cluster to Humanitec

locals {
  ingress_address = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
}

data "aws_elb_hosted_zone_id" "main" {}

resource "humanitec_resource_definition" "k8s_cluster_driver" {
  driver_type = "humanitec/k8s-cluster-eks"
  id          = var.cluster_name
  name        = var.cluster_name
  type        = "k8s-cluster"

  driver_inputs = {
    values_string = jsonencode({
      "name"                     = module.aws_eks.cluster_name
      "loadbalancer"             = local.ingress_address
      "loadbalancer_hosted_zone" = data.aws_elb_hosted_zone_id.main.id
      "region"                   = var.region
    }),
    secrets_string = jsonencode({
      "credentials" = {
        "aws_access_key_id"     = aws_iam_access_key.humanitec_svc.id
        "aws_secret_access_key" = aws_iam_access_key.humanitec_svc.secret
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_cluster_driver" {
  resource_definition_id = humanitec_resource_definition.k8s_cluster_driver.id
  env_type               = var.environment
}


resource "humanitec_resource_definition" "k8s_logging" {
  driver_type = "humanitec/logging-k8s"
  id          = "default-logging"
  name        = "default-logging"
  type        = "logging"

  driver_inputs = {}
}

resource "humanitec_resource_definition_criteria" "k8s_logging" {
  resource_definition_id = humanitec_resource_definition.k8s_logging.id
}


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
