# base

Module that provides the reference architecture.

## Terraform docs

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 4.50 |
| helm | ~> 2.12 |
| humanitec | ~> 1.0 |
| kubernetes | >= 2.0.3 |
| random | ~> 3.5 |

### Providers

| Name | Version |
|------|---------|
| aws | >= 4.50 |
| helm | ~> 2.12 |
| humanitec | ~> 1.0 |
| kubernetes | >= 2.0.3 |
| random | ~> 3.5 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| aws\_eks | terraform-aws-modules/eks/aws | ~> 20.2 |
| aws\_vpc | terraform-aws-modules/vpc/aws | ~> 5.1 |
| ebs\_csi\_irsa\_role | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.30 |

### Resources

| Name | Type |
|------|------|
| [aws_iam_role.humanitec_svc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.humanitec_svc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [humanitec_resource_account.cluster_account](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_account) | resource |
| [humanitec_resource_definition.k8s_cluster_driver](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition.k8s_namespace](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [humanitec_resource_definition_criteria.k8s_cluster_driver](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [humanitec_resource_definition_criteria.k8s_namespace](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition_criteria) | resource |
| [random_password.external_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_elb_hosted_zone_id.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_hosted_zone_id) | data source |
| [aws_iam_policy_document.instance_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubernetes_service.ingress_nginx_controller](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_k8s\_access\_entries | Additional access entries add to the k8s aws-auth configmap | <pre>list(object({<br>    id            = string<br>    principal_arn = string<br>    groups        = list(string)<br>  }))</pre> | `[]` | no |
| capacity\_type | Defines whether to use ON\_DEMAND or SPOT EC2 instances for EKS nodes | `string` | `"ON_DEMAND"` | no |
| cluster\_name | Name for the EKS cluster | `string` | `"ref-arch"` | no |
| cluster\_version | Version of the EKS cluster to deploy | `string` | `null` | no |
| disk\_size | Disk size in GB to use for EKS nodes | `number` | `20` | no |
| eks\_public\_access\_cidrs | List of CIDRs that can access the EKS cluster's public endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| environment | Name of the environment to be deployed into | `string` | `"development"` | no |
| iam\_role\_name | Name of the IAM user to create for Humanitec EKS access | `string` | `"svc-humanitec"` | no |
| ingress\_nginx\_min\_unavailable | Number of allowed unavaiable replicas for the ingress-nginx controller | `number` | `1` | no |
| ingress\_nginx\_replica\_count | Number of replicas for the ingress-nginx controller | `number` | `2` | no |
| instance\_types | List of EC2 instances types to use for EKS nodes | `list(string)` | <pre>[<br>  "t3.large"<br>]</pre> | no |
| node\_group\_desired\_size | Desired number of nodes for the EKS node group | `number` | `3` | no |
| node\_group\_max\_size | Maximum number of nodes for the EKS node group | `number` | `3` | no |
| node\_group\_min\_size | Minimum number of nodes for the EKS node group | `number` | `2` | no |
| region | AWS Region to deploy into | `string` | `"us-east-1"` | no |
| vpc\_name | AWS VPC name | `string` | `"ref-arch"` | no |

### Outputs

| Name | Description |
|------|-------------|
| eks\_cluster\_certificate\_authority\_data | Base64 encoded certificate data required to communicate with the cluster |
| eks\_cluster\_endpoint | Endpoint for your Kubernetes API server |
| eks\_cluster\_name | The name of the EKS cluster |
| eks\_oidc\_provider | The OpenID Connect identity provider (issuer URL without leading `https://`) |
| eks\_oidc\_provider\_arn | The ARN of the OIDC Provider |
| environment | Name of the environment to be deployed into |
| humanitec\_resource\_account\_id | Humanitec resource account id for the cluster |
| ingress\_nginx\_external\_dns | External DNS entry for the Nginx ingress controller |
| vpc\_id | VPC id |
<!-- END_TF_DOCS -->
