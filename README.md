# Humanitec AWS Reference Architecture

> TL;DR
>
> Skip the theory? Go [here](README.md#how-to-spin-up-your-humanitec-aws-reference-architecture) to spin up your Humanitec AWS Reference Architecture Implementation.
>
> [Follow this learning path to master your Internal Developer Platform](https://developer.humanitec.com/training/master-your-internal-developer-platform/introduction/).
>

Building an Internal Developer Platform (IDP) can come with many challenges. To give you a head start, we’ve created a set of [reference architectures](https://humanitec.com/reference-architectures) based on hundreds of real-world setups. These architectures described in code provide a starting point to build your own IDP within minutes, along with customization capabilities to ensure your platform meets the unique needs of your users (developers).

The initial version of this reference architecture has been presented by Mike Gatto, Sr. DevOps Engineer, McKinsey and Stephan Schneider, Digital Expert Associate Partner, McKinsey at [PlartformCon 2023](https://www.youtube.com/watch?v=AimSwK8Mw-U).

## What is an Internal Developer Platform (IDP)?

An [Internal Developer Platform (IDP)](https://humanitec.com/blog/what-is-an-internal-developer-platform) is the sum of all the tech and tools that a platform engineering team binds together to pave golden paths for developers. IDPs lower cognitive load across the engineering organization and enable developer self-service, without abstracting away context from developers or making the underlying tech inaccessible. Well-designed IDPs follow a Platform as a Product approach, where a platform team builds, maintains, and continuously improves the IDP, following product management principles and best practices.

## Understanding the different planes of the IDP reference architecture

When McKinsey originally [published the reference architecture](https://www.youtube.com/watch?v=AimSwK8Mw-U) they proposed five planes that describe the different parts of a modern Internal Developer Platform (IDP).

![AWS reference architecture Humanitec](docs/images/AWS-reference-architecture-Humanitec.png)

### Developer Control Plane

This plane is the primary configuration layer and interaction point for the platform users. It harbors the following components:

* A **Version Control System**. GitHub is a prominent example, but this can be any system that contains two types of repositories:
  * Application Source Code
  * Platform Source Code, e.g. using Terraform
* **Workload specifications**. The reference architecture uses [Score](https://developer.humanitec.com/score/overview/).
* A **portal** for developers to interact with. It can be the Humanitec Portal, but you might also use [Backstage](https://backstage.io/) or any other portal on the market.

### Integration and Delivery Plane

This plane is about building and storing the image, creating app and infra configs from the abstractions provided by the developers, and deploying the final state. It’s where the domains of developers and platform engineers meet.

This plane usually contains four different tools:

* A **CI pipeline**. It can be Github Actions or any CI tooling on the market.
* The **image registry** holding your container images. Again, this can be any registry on the market.
* An **orchestrator** which in our example, is the Humanitec Platform Orchestrator.
* The **CD system**, which can be the Platform Orchestrator’s deployment pipeline capabilities — an external system triggered by the Orchestrator using a webhook, or a setup in tandem with GitOps operators like ArgoCD.

### Monitoring and Logging Plane

The integration of monitoring and logging systems varies greatly depending on the system. This plane however is not a focus of the reference architecture.

### Security Plane

The security plane of the reference architecture is focused on the secrets management system. The secrets manager stores configuration information such as database passwords, API keys, or TLS certificates needed by an Application at runtime. It allows the Platform Orchestrator to reference the secrets and inject them into the Workloads dynamically. You can learn more about secrets management and integration with other secrets management [here](https://developer.humanitec.com/platform-orchestrator/security/overview).

The reference architecture sample implementations use the secrets store attached to the Humanitec SaaS system.

### Resource Plane

This plane is where the actual infrastructure exists including clusters, databases, storage, or DNS services. The configuration of the Resources is managed by the Platform Orchestrator which dynamically creates app and infrastructure configurations with every deployment and creates, updates, or deletes dependent Resources as required.

## How to spin up your Humanitec AWS Reference Architecture

This repo contains an implementation of part of the Humanitec Reference Architecture for an Internal Developer Platform, including Backstage as optional Portal solution.

This repo covers the base layer of the implementation for AWS.

By default, the following will be provisioned:

* VPC
* EKS Cluster
* IAM User to access the cluster
* Ingress NGINX in the cluster
* Resource Definitions in Humanitec for:
  * Kubernetes Cluster

### Prerequisites

* A Humanitec account with the `Administrator` role in an Organization. Get a [free trial](https://humanitec.com/free-trial?utm_source=github&utm_medium=referral&utm_campaign=aws_refarch_repo) if you are just starting.
* An AWS account
* [AWS CLI](https://aws.amazon.com/cli/) installed locally
* [terraform](https://www.terraform.io/) installed locally
* (Optional) [Humanitec CLI](https://developer.humanitec.com/platform-orchestrator/cli/) installed locally
* (Optional) [GitHub CLI](https://cli.github.com/) installed locally

### Usage

**Note: Using this Reference Architecture Implementation will incur costs for your AWS project.**

It is recommended that you fully review the code before you run it to ensure you understand the impact of provisioning this infrastructure.
Humanitec does not take responsibility for any costs incurred or damage caused when using the Reference Architecture Implementation.

This reference architecture implementation uses Terraform. You will need to do the following:

1. [Fork this GitHub repo](https://github.com/humanitec-architecture/reference-architecture-aws/fork), clone it to your local machine and navigate to the root of the repository.

2. Set the required input variables. (see [Required input variables](#required-input-variables))

3. Ensure you are logged in with `aws`. (Follow the [quickstart](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) if you aren't)

4.
   1. Login to Humanitec (your user needs to have the `Administrator` role on the Humanitec Organization)

      ```shell
      humctl login
      ```

   2. Alternatively: Set the `HUMANITEC_TOKEN` environment variable to an appropriate Humanitec API token with the `Administrator` role on the Humanitec Organization.

   For example:

   ```shell
   export HUMANITEC_TOKEN="my-humanitec-api-token"
   ```

5. Run terraform:

   ```shell
   terraform init
   terraform plan
   terraform apply
   ```

#### Required input variables

Terraform reads variables by default from a file called `terraform.tfvars`. You can create your own file by renaming the `terraform.tfvars.example` file in the root of the repo and then filling in the missing values.

You can see find a details about each of those variables and additional supported variables under [Inputs](#inputs).

### Verify your result

Check for the existence of key elements of the reference architecture. This is a subset of all elements only. For a complete list of what was installed, review the Terraform code.

1. Set the `HUMANITEC_ORG` environment variable to the ID of your Humanitec Organization (must be all lowercase):

   ```shell
   export HUMANITEC_ORG="my-humanitec-org"
   ```

2. Verify the existence of the Resource Definition for the EKS cluster in your Humanitec Organization:

   ```shell
   curl -s https://api.humanitec.io/orgs/${HUMANITEC_ORG}/resources/defs/ref-arch \
     --header "Authorization: Bearer ${HUMANITEC_TOKEN}" \
     | jq .id,.type
   ```

   This should output:

   ```shell
   "ref-arch"
   "k8s-cluster"
   ```

3. Verify the existence of the newly created EKS cluster:

   ```shell
   aws eks list-clusters --region <your-region>
   ```

   This should output:

   ```json
   {
       "clusters": [
           "ref-arch",
           "[more previously existing clusters here]"
       ]
   }
   ```

### Enable a portal (optional)

#### Portal Prerequisites

Backstage requires a GitHub connection, which in turn needs:

* A GitHub organization and permission to create new repositories in it. Go to <https://github.com/account/organizations/new> to create a new org (the "Free" option is fine). Note: is has to be an organization, a free account is not sufficient.

* Configured GitHub access
  * Either using the GitHub CLI:

    ```shell
    gh auth login --scopes repo,workflow,admin:org,delete_repo
    ```

  * Or using a token:
    * Create a classic github personal access token with `repo`, `workflow`, `delete_repo` and `admin:org` scope [here](https://github.com/settings/tokens).
    * Set the `GITHUB_TOKEN` environment variable to your token.

      ```shell
      export GITHUB_TOKEN="my-github-token"
      ```

* Set the `GITHUB_ORG_ID` environment variable to your GitHub organization ID.

  ```shell
  export GITHUB_ORG_ID="my-github-org-id"
  ```

* Install the GitHub App for Backstage into your GitHub organization
  * Run `docker run --rm -it -e GITHUB_ORG_ID -v $(pwd):/pwd -p 127.0.0.1:3000:3000 ghcr.io/humanitec-architecture/create-gh-app` ([image source](https://github.com/humanitec-architecture/create-gh-app/)) and follow the instructions:
    * “All repositories” ~> Install
    * “Okay, […] was installed on the […] account.” ~> You can close the window and server.

#### Portal Usage

* Enable `with_backstage` inside your `terraform.tfvars` and configure the additional variables that a required for Backstage.
* Perform another `terraform apply`

#### Verify portal setup

* [Fetch the DNS entry](https://developer.humanitec.com/score/getting-started/get-dns/) of the Humanitec Application `backstage`, Environment `development`.
* Open the host in your browser.
* Click the "Create" button and scaffold your first application.

### Cleaning up

Once you are finished with the reference architecture, you can remove all provisioned infrastructure and the resource definitions created in Humanitec with the following:

1. Delete all Humanitec Applications scaffolded using the Portal, if you used one, but not the `backstage` app itself.

2. Ensure you are (still) logged in with `aws`.

3. Ensure you still have the `HUMANITEC_TOKEN` environment variable set to an appropriate Humanitec API token with the `Administrator` role on the Humanitec Organization.

4. Run terraform:

   ```shell
   terraform destroy
   ```

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
| humanitec | ~> 1.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| base | ./modules/base | n/a |
| github | ./modules/github | n/a |
| github\_app | github.com/humanitec-architecture/shared-terraform-modules | v2024-06-12//modules/github-app |
| portal\_backstage | ./modules/portal-backstage | n/a |

### Resources

| Name | Type |
|------|------|
| [humanitec_service_user_token.deployer](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/service_user_token) | resource |
| [humanitec_user.deployer](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/user) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_account\_id | AWS Account (ID) to use | `string` | n/a | yes |
| aws\_region | AWS region | `string` | n/a | yes |
| disk\_size | Disk size in GB to use for EKS nodes | `number` | `20` | no |
| github\_org\_id | GitHub org id (required for Backstage) | `string` | `null` | no |
| humanitec\_org\_id | Humanitec Organization ID (required for Backstage) | `string` | `null` | no |
| instance\_types | List of EC2 instances types to use for EKS nodes | `list(string)` | <pre>[<br>  "t3.large"<br>]</pre> | no |
| with\_backstage | Deploy Backstage | `bool` | `false` | no |
<!-- END_TF_DOCS -->

## Learn more

Expand your knowledge by heading over to our learning path, and discover how to:

* Deploy the Humanitec reference architecture using a cloud provider of your choice
* Deploy and manage Applications using the Humanitec Platform Orchestrator and Score
* Provision additional Resources and connect to them
* Achieve standardization by design
* Deal with special scenarios

[Master your Internal Developer Platform](https://developer.humanitec.com/training/master-your-internal-developer-platform/introduction/)

* [Introduction](https://developer.humanitec.com/training/master-your-internal-developer-platform/introduction/)
* [Design principles](https://developer.humanitec.com/training/master-your-internal-developer-platform/design-principles/)
* [Structure and integration points](https://developer.humanitec.com/training/master-your-internal-developer-platform/structure-and-integration-points/)
* [Dynamic Configuration Management](https://developer.humanitec.com/training/master-your-internal-developer-platform/dynamic-config-management/)
* [Tutorial: Set up the reference architecture in your cloud](https://developer.humanitec.com/training/master-your-internal-developer-platform/setup-ref-arch-in-your-cloud/)
* [Theory on developer workflows](https://developer.humanitec.com/training/master-your-internal-developer-platform/theory-on-dev-workflows/)
* [Tutorial: Scaffold a new Workload and create staging and prod Environments](https://developer.humanitec.com/training/master-your-internal-developer-platform/scaffolding-a-new-workload/)
* [Tutorial: Deploy an Amazon S3 Resource to production](https://developer.humanitec.com/training/master-your-internal-developer-platform/deploy-a-resource/)
* [Tutorial: Perform daily developer activities (debug, rollback, diffs, logs)](https://developer.humanitec.com/training/master-your-internal-developer-platform/daily-activities/)
* [Tutorial: Deploy ephemeral Environments](https://developer.humanitec.com/training/master-your-internal-developer-platform/deploy-ephemeral-environments/)
* [Theory on platform engineering workflows](https://developer.humanitec.com/training/master-your-internal-developer-platform/theory-on-pe-workflows/)
* [Resource management theory](https://developer.humanitec.com/training/master-your-internal-developer-platform/resource-management-theory/)
* [Tutorial: Provision a Redis cluster on AWS using Terraform](https://developer.humanitec.com/training/master-your-internal-developer-platform/provision-redis-aws/)
* [Tutorial: Update Resource Definitions for related Applications](https://developer.humanitec.com/training/master-your-internal-developer-platform/update-resource-definitions-for-related-applications/)
