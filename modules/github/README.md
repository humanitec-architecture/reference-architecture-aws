# GitHub

This module prepares a GitHub Organization to be used for scaffolding using a Portal.

## Terraform docs

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 5.17 |
| github | ~> 5.38 |

### Providers

| Name | Version |
|------|---------|
| aws | ~> 5.17 |
| github | ~> 5.38 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| iam\_github\_oidc\_provider | terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider | ~> 5.30 |
| iam\_github\_oidc\_role | terraform-aws-modules/iam/aws//modules/iam-github-oidc-role | ~> 5.30 |

### Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ecr_push_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [github_actions_organization_secret.backstage_humanitec_token](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_secret) | resource |
| [github_actions_organization_variable.backstage_aws_region](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) | resource |
| [github_actions_organization_variable.backstage_aws_role_arn](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) | resource |
| [github_actions_organization_variable.backstage_cloud_provider](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) | resource |
| [github_actions_organization_variable.backstage_humanitec_org_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_region | AWS region | `string` | n/a | yes |
| github\_org\_id | GitHub org id | `string` | n/a | yes |
| humanitec\_ci\_service\_user\_token | Humanitec CI Service User Token | `string` | n/a | yes |
| humanitec\_org\_id | Humanitec Organization ID | `string` | n/a | yes |
<!-- END_TF_DOCS -->
