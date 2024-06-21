# Portal: Backstage

This module deploys the [Humanitec Reference Architecture Backstage](https://github.com/humanitec-architecture/backstage) as Application into a specific Humanitec Organization.

## Terraform docs

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 5.17 |
| humanitec | ~> 1.0 |

### Providers

| Name | Version |
|------|---------|
| aws | ~> 5.17 |
| humanitec | ~> 1.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| backstage\_postgres | github.com/humanitec-architecture/resource-packs-in-cluster | v2024-06-05//humanitec-resource-defs/postgres/basic |
| portal\_backstage | github.com/humanitec-architecture/shared-terraform-modules | v2024-06-12//modules/portal-backstage |

### Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.backstage_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.backstage_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [humanitec_application.backstage](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/application) | resource |
| [humanitec_resource_definition_criteria.backstage_postgres](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| github\_app\_client\_id | GitHub App Client ID | `string` | n/a | yes |
| github\_app\_client\_secret | GitHub App Client Secret | `string` | n/a | yes |
| github\_app\_id | GitHub App ID | `string` | n/a | yes |
| github\_app\_private\_key | GitHub App Private Key | `string` | n/a | yes |
| github\_org\_id | GitHub org id | `string` | n/a | yes |
| github\_webhook\_secret | GitHub Webhook Secret | `string` | n/a | yes |
| humanitec\_ci\_service\_user\_token | Humanitec CI Service User Token | `string` | n/a | yes |
| humanitec\_org\_id | Humanitec Organization ID | `string` | n/a | yes |
| humanitec\_secret\_store\_id | Humanitec Secret Store ID | `string` | n/a | yes |
<!-- END_TF_DOCS -->
