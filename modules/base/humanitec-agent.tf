# Installs the humanitec-agent into the cluster

# More details https://developer.humanitec.com/integration-and-extensions/humanitec-agent/overview/

resource "kubernetes_namespace" "agent-namespace" {
  metadata {
    labels = {
      "app.kubernetes.io/name"     = "humanitec-operator"
      "app.kubernetes.io/instance" = "humanitec-operator"
    }

    name = "humanitec-agent"
  }
}

resource "tls_private_key" "agent_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  agent_id = "${local.res_def_prefix}agent"
}

resource "humanitec_agent" "agent" {
  id          = local.agent_id
  description = "reference-architecture-aws"
  public_keys = [{
    key = tls_private_key.agent_private_key.public_key_pem
  }]
}

resource "helm_release" "humanitec_agent" {
  name      = "humanitec-agent"
  namespace = kubernetes_namespace.agent-namespace.id

  repository = "oci://ghcr.io/humanitec/charts"
  chart      = "humanitec-agent"
  version    = "1.1.0"
  wait       = true
  timeout    = 300

  set {
    name  = "humanitec.org"
    value = var.humanitec_org_id
  }

  set {
    name  = "humanitec.privateKey"
    value = tls_private_key.agent_private_key.private_key_pem
  }

  depends_on = [
    humanitec_agent.agent
  ]
}

resource "humanitec_resource_definition" "agent" {
  id   = local.agent_id
  name = local.agent_id
  type = "agent"

  driver_type = "humanitec/agent"
  driver_inputs = {
    values_string = jsonencode({
      id = local.agent_id
    })
  }

  depends_on = [
    helm_release.humanitec_agent
  ]
}

resource "humanitec_resource_definition_criteria" "agent" {
  resource_definition_id = humanitec_resource_definition.agent.id
  res_id                 = "agent"
  env_type               = var.environment

  force_delete = true
}
