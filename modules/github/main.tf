locals {
  cloud_provider = "aws"
}

# Configure GitHub variables & secrets for all scaffolded apps

resource "github_actions_organization_variable" "backstage_cloud_provider" {
  variable_name = "CLOUD_PROVIDER"
  visibility    = "all"
  value         = local.cloud_provider
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
