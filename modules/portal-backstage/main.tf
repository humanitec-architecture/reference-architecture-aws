resource "humanitec_application" "backstage" {
  id   = "backstage"
  name = "backstage"
}

module "portal_backstage" {
  # Not pinned as we don't have a release yet
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/humanitec-architecture/shared-terraform-modules?ref=v2024-06-06//modules/portal-backstage"

  cloud_provider = "aws"

  humanitec_org_id                = var.humanitec_org_id
  humanitec_app_id                = humanitec_application.backstage.id
  humanitec_ci_service_user_token = var.humanitec_ci_service_user_token

  github_org_id            = var.github_org_id
  github_app_client_id     = var.github_app_client_id
  github_app_client_secret = var.github_app_client_secret
  github_app_id            = var.github_app_id
  github_app_private_key   = var.github_app_private_key
  github_webhook_secret    = var.github_webhook_secret
}

# Configure required resources for backstage

locals {
  res_def_prefix = "backstage-"
}

# in-cluster postgres

module "backstage_postgres" {
  source = "github.com/humanitec-architecture/resource-packs-in-cluster?ref=v2024-06-05//humanitec-resource-defs/postgres/basic"

  prefix = local.res_def_prefix
}

resource "humanitec_resource_definition_criteria" "backstage_postgres" {
  resource_definition_id = module.backstage_postgres.id
  app_id                 = humanitec_application.backstage.id

  force_delete = true
}
