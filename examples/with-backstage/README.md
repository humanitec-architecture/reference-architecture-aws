# AWS reference architecture with Backstage

Provisions the AWS reference architecture connected to Humanitec and installs Backstage.

## Prerequisites

* The same prerequisites as the [base reference architecture](../../README.md#prerequisites), plus the following items.
* A GitHub organization and permission to create new repositories in it. Go to <https://github.com/account/organizations/new> to create a new org (the "Free" option is fine). Note: is has to be an organization, a free account is not sufficient.
* Create a classic github personal access token with `repo`, `workflow`, `delete_repo` and `admin:org` scope [here](https://github.com/settings/tokens).
* Set the `GITHUB_TOKEN` environment variable to your token.

  ```bash
  export GITHUB_TOKEN="my-github-token"
  ```

* Set the `GITHUB_ORG_ID` environment variable to your GitHub organization ID.

  ```bash
  export GITHUB_ORG_ID="my-github-org-id"
  ```

* [Node.js](https://nodejs.org) installed locally.
* Install the GitHub App for Backstage into your GitHub organization
  * Run `docker run --rm -it -e GITHUB_ORG_ID -v $(pwd):/pwd -p 127.0.0.1:3000:3000 ghcr.io/humanitec-architecture/create-gh-app` ([image source](https://github.com/humanitec-architecture/create-gh-app/)) and follow the instructions:
    * “All repositories” ~> Install
    * “Okay, […] was installed on the […] account.” ~> You can close the window and server.

## Usage

Follow the same steps as for the [base layer](../../README.md#usage), applying these modifications:

* Execute `cd ./examples/with-backstage` after cloning the repo. Execute all subsequent commands in this directory.
* In particular, use the `./examples/with-backstage/terraform.tfvars.example` file as the basis for your `terraform.tfvars` file. It defines additional variables needed to setup and configure Backstage.

## Verify your result

Check for the existence of key elements of the backstage module. This is a subset of all elements only. For a complete list of what was installed, review the Terraform code.

1. Perform the [verification steps of the base installation](../../README.md) if you have not already done so.
2. Verify the existence of the Backstage Application in your Humanitec Organization:

   ```
   curl -s https://api.humanitec.io/orgs/${HUMANITEC_ORG}/apps/backstage \
     --header "Authorization: Bearer ${HUMANITEC_TOKEN}"
   ```

   This should output a JSON formatted representation of the Application like so:

   ```
   {"id":"backstage","name":"backstage","created_at":"2023-10-02T13:44:27Z","created_by":"s-d3e94a0e-8b53-29f9-b666-27548b7e06e0","envs":[{"id":"development","name":"Development","type":"development"}]}
   ```

   You can also check for the Application in the [Humanitec Platform Orchestrator UI](https://app.humanitec.io).

3. Connect to your EKS cluster via `kubectl`. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html) or use this command:

   ```
   aws eks update-kubeconfig --region <my-aws-region> --name ref-arch
   ```

4. Get the elements in the newly created Kubernetes namespace:

   ```
   kubectl get all -n backstage-development
   ```

   You should see
   * a `deployment`, `replicaset`, running `pod`, and `service` for Backstage
   * a `statefulset`, running `pod`, and `service` for PostgreSQL database used by Backstage.

   Note: it may take up to ten minutes after the `terraform apply` completed until you actually see those resources. The Backstage application needs to built and deployed via a GitHub action out of the newly created repository in your GitHub organization.

## Cleaning up

Once you are finished with the reference architecture, you can remove all provisioned infrastrcuture and the resource definitions created in Humanitec with the following:

1. Delete all Humanitec applications scaffolded using Backstage, but not the `backstage` app itself.

2. Follow the [base reference architecture cleanup instructions](../../README.md#cleaning-up).

## Terraform docs

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 5.17 |
| github | ~> 5.38 |
| helm | ~> 2.12 |
| humanitec | ~> 1.0 |
| kubernetes | ~> 2.25 |
| random | ~> 3.5 |

### Providers

| Name | Version |
|------|---------|
| aws | ~> 5.17 |
| github | ~> 5.38 |
| humanitec | ~> 1.0 |
| random | ~> 3.5 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| backstage\_ecr | terraform-aws-modules/ecr/aws | ~> 1.6 |
| backstage\_mysql | github.com/humanitec-architecture/resource-packs-in-cluster | v2024-06-05//humanitec-resource-defs/mysql/basic |
| backstage\_postgres | github.com/humanitec-architecture/resource-packs-in-cluster | v2024-06-05//humanitec-resource-defs/postgres/basic |
| base | ../../modules/base | n/a |
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
| [github_repository.backstage](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [humanitec_application.backstage](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/application) | resource |
| [humanitec_resource_definition_criteria.backstage_mysql](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.backstage_postgres](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_value.app_config_backend_auth_keys](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.aws_default_region](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_cloud_provider](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_github_app_client_id](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_github_app_client_secret](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_github_app_id](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_github_app_private_key](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_github_app_webhook_secret](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_github_org_id](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_humanitec_org](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [humanitec_value.backstage_humanitec_token](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/value) | resource |
| [random_bytes.backstage_service_to_service_auth_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/bytes) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_account\_id | AWS Account (ID) to use | `string` | n/a | yes |
| aws\_region | AWS region | `string` | n/a | yes |
| github\_org\_id | GitHub org id | `string` | n/a | yes |
| humanitec\_ci\_service\_user\_token | Humanitec CI Service User Token | `string` | n/a | yes |
| humanitec\_org\_id | Humanitec Organization ID | `string` | n/a | yes |
| disk\_size | Disk size in GB to use for EKS nodes | `number` | `20` | no |
| instance\_types | List of EC2 instances types to use for EKS nodes | `list(string)` | <pre>[<br>  "t3.large"<br>]</pre> | no |
<!-- END_TF_DOCS -->
