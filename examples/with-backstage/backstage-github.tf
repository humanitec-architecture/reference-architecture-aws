# Configure GitHub variables & secrets for Backstage itself and for all scaffolded apps

locals {
  github_app_credentials_file = "github-app-credentials.json"
  github_app_credentials      = jsondecode(file("${path.module}/${local.github_app_credentials_file}"))
  github_app_id               = local.github_app_credentials["appId"]
  github_app_client_id        = local.github_app_credentials["clientId"]
  github_app_client_secret    = local.github_app_credentials["clientSecret"]
  github_app_private_key      = local.github_app_credentials["privateKey"]
  github_webhook_secret       = local.github_app_credentials["webhookSecret"]
}

locals {
  backstage_repo = "backstage"
}

resource "github_actions_organization_variable" "backstage_aws_region" {
  variable_name = "AWS_REGION"
  visibility    = "all"
  value         = var.aws_region
}

resource "github_actions_organization_variable" "backstage_aws_role_arn" {
  variable_name = "AWS_ROLE_ARN"
  visibility    = "all"
  value         = module.iam_github_oidc_role.arn
}

resource "github_actions_organization_variable" "backstage_humanitec_org_id" {
  variable_name = "HUMANITEC_ORG_ID"
  visibility    = "all"
  value         = var.humanitec_org_id
}

resource "github_actions_organization_secret" "backstage_humanitec_token" {
  secret_name     = "HUMANITEC_TOKEN"
  visibility      = "all"
  plaintext_value = var.humanitec_ci_service_user_token
}

# Backstage repository itself

resource "github_repository" "backstage" {
  name        = local.backstage_repo
  description = "Backstage"

  visibility = "public"

  template {
    owner      = "humanitec-architecture"
    repository = "backstage"
  }

  depends_on = [
    module.base,
    module.backstage_ecr,
    module.iam_github_oidc_role,
    humanitec_application.backstage,
    humanitec_resource_definition_criteria.backstage_postgres,
    github_actions_organization_secret.backstage_humanitec_token,
  ]
}
