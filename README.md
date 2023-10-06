# Humanitec AWS Reference Architecture

This repo contains an implementation of part of the Humanitec Reference Architecture for an Internal Developer Platform.

To install an implementation containing add-ons, follow the separate README. We currently feature these add-ons:

* [Base layer plus Backstage](examples/with-backstage/)

![AWS reference architecture Humanitec](docs/images/AWS-reference-architecture-Humanitec.png)

This repo covers the base layer of the implementation for AWS.

By default, the following will be provisioned:

- VPC
- EKS Cluster
- IAM User to access the cluster
- Ingress NGINX in the cluster
- Resource Definitions in Humanitec for:
  - Kubernetes Cluster
  - Logging

## Prerequisites

* A Humanitec account with the `Administrator` role in an Organization. Get a [free trial](https://humanitec.com/free-trial?utm_source=github&utm_medium=referral&utm_campaign=aws_refarch_repo) if you are just starting.
* An AWS account
* [AWS CLI](https://aws.amazon.com/cli/) installed locally
* [terraform](https://www.terraform.io/) installed locally

## Usage

**Note: Using this Reference Architecture Implementation will incur costs for your AWS project.**

It is recommended that you fully review the code before you run it to ensure you understand the impact of provisioning this infrastructure.
Humanitec does not take responsibility for any costs incurred or damage caused when using the Reference Architecture Implementation.

This reference architecture implementation uses Terraform. You will need to do the following:

1. [Fork this GitHub repo](https://github.com/humanitec-architecture/reference-architecture-aws/fork), clone it to your local machine and navigate to the root of the repository.

2. Set the required input variables. (see [Required input variables](#required-input-variables))

3. Ensure you are logged in with `aws`. (Follow the [quickstart](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) if you aren't)

4. Set the `HUMANITEC_TOKEN` environment variable to an appropriate Humanitec API token with the `Administrator` role on the Humanitec Organization.

   For example:

   ```
   export HUMANITEC_TOKEN="my-humanitec-api-token"
   ```

5. Run terraform:

   ```
   terraform init
   terraform plan
   terraform apply
   ```

   `terraform plan` and `apply` might output this message:
   ```   
   │ Warning: Argument is deprecated
   │
   │   with module.base.module.aws_eks.aws_eks_addon.this["aws-ebs-csi-driver"],
   │   [...]
   ```
   This is due to an upstream issue with the Terraform AWS modules, and can be ignored.

### Required input variables

Terraform reads variables by default from a file called `terraform.tfvars`. You can create your own file by renaming the `terraform.tfvars.example` file in the root of the repo and then filling in the missing values.

You can see find a details about each of those variables and additional supported variables under [Inputs](#inputs).


## Verify your result

Check for the existence of key elements of the reference architecture. This is a subset of all elements only. For a complete list of what was installed, review the Terraform code.

1. Set the `HUMANITEC_ORG` environment variable to the ID of your Humanitec Organization (must be all lowercase):

   ```
   export HUMANITEC_ORG="my-humanitec-org"
   ```

2. Verify the existence of the Resource Definition for the EKS cluster in your Humanitec Organization:

   ```
   curl -s https://api.humanitec.io/orgs/${HUMANITEC_ORG}/resources/defs/ref-arch \
     --header "Authorization: Bearer ${HUMANITEC_TOKEN}" \
     | jq .id,.type
   ```
   
   This should output:
   ```
   "ref-arch"
   "k8s-cluster"
   ```

3. Verify the existence of the newly created EKS cluster:

   ```
   aws eks list-clusters --region <your-region>
   ```
   
   This should output:
   
   ```
   {
       "clusters": [
           "ref-arch",
           "[more previously existing clusters here]"
       ]
   }
   ```

## Cleaning up

Once you are finished with the reference architecture, you can remove all provisioned infrastrcuture and the resource definitions created in Humanitec with the following:

1. Ensure you are (still) logged in with `aws`.

2. Ensure you still have the `HUMANITEC_TOKEN` environment variable set to an appropriate Humanitec API token with the `Administrator` role on the Humanitec Organization.

3. Run terraform:

   ```
   terraform destroy
   ```

## Terraform docs

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 5.17 |
| humanitec | ~> 0.13 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| base | ./modules/base | n/a |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_account\_id | AWS Account (ID) to use | `string` | n/a | yes |
| aws\_region | AWS Region to deploy into | `string` | n/a | yes |
| humanitec\_org\_id | Humanitec Organization ID | `string` | n/a | yes |
<!-- END_TF_DOCS -->
