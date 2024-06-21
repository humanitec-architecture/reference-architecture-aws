# General outputs

output "environment" {
  description = "Name of the environment to be deployed into"
  value       = var.environment
}

# VPC outputs

output "vpc_id" {
  description = "VPC id"
  value       = module.aws_vpc.vpc_id
}

# EKS outputs

output "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.aws_eks.oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.aws_eks.oidc_provider_arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.aws_eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.aws_eks.cluster_certificate_authority_data
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.aws_eks.cluster_name
}

# Ingress outputs

output "ingress_nginx_external_dns" {
  description = "External DNS entry for the Nginx ingress controller"
  value       = local.ingress_address
}


# Humanitec

output "humanitec_resource_account_id" {
  description = "Humanitec resource account id for the cluster"
  value       = humanitec_resource_account.cluster_account.id
}

output "humanitec_secret_store_id" {
  description = "Humanitec secret store id"
  value       = humanitec_secretstore.main.id
}
