# AWS reference architecture

module "base" {
  source = "./modules/base"

  region         = var.aws_region
  instance_types = var.instance_types
  disk_size      = var.disk_size
}

module "github" {
  count = var.with_backstage ? 1 : 0

  source = "./modules/github"

  humanitec_org_id                = var.humanitec_org_id
  humanitec_ci_service_user_token = var.humanitec_ci_service_user_token
  aws_region                      = var.aws_region
  github_org_id                   = var.github_org_id

  depends_on = [module.base]
}

# Configure GitHub variables & secrets for Backstage itself and for all scaffolded apps

locals {
  github_app_credentials_file = "github-app-credentials.json"
}

module "github_app" {
  count = var.with_backstage ? 1 : 0

  # Not pinned as we don't have a release yet
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/humanitec-architecture/shared-terraform-modules?ref=v2024-06-06//modules/github-app"

  credentials_file = "${path.module}/${local.github_app_credentials_file}"
}

# Deploy Backstage as Portal

module "portal_backstage" {
  count = var.with_backstage ? 1 : 0

  source = "./modules/portal-backstage"

  humanitec_org_id                = var.humanitec_org_id
  humanitec_ci_service_user_token = var.humanitec_ci_service_user_token

  github_org_id            = var.github_org_id
  github_app_client_id     = module.github_app[0].client_id
  github_app_client_secret = module.github_app[0].client_secret
  github_app_id            = module.github_app[0].app_id
  github_app_private_key   = module.github_app[0].private_key
  github_webhook_secret    = module.github_app[0].webhook_secret

  depends_on = [module.github]
}
