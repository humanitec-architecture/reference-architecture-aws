variable "eks_public_access_cidrs" {
  description = "List of CIDRs that can access the EKS cluster's public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "region" {
  description = "AWS Region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "AWS VPC name"
  type        = string
  default     = "ref-arch"
}

variable "environment" {
  description = "Name of the environment to be deployed into"
  type        = string
  default     = "development"
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
  default     = "ref-arch"
}

variable "cluster_version" {
  description = "Version of the EKS cluster to deploy"
  type        = string
  default     = null
}

variable "node_group_min_size" {
  description = "Minimum number of nodes for the EKS node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of nodes for the EKS node group"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "Desired number of nodes for the EKS node group"
  type        = number
  default     = 3
}

variable "instance_types" {
  description = "List of EC2 instances types to use for EKS nodes"
  type        = list(string)
  default = [
    "t3.large"
  ]
}

variable "capacity_type" {
  description = "Defines whether to use ON_DEMAND or SPOT EC2 instances for EKS nodes"
  type        = string
  default     = "ON_DEMAND"
}

variable "iam_user_name" {
  description = "Name of the IAM user to create for Humanitec EKS access"
  type        = string
  default     = "svc-humanitec"
}

variable "additional_aws_auth_users" {
  description = "Additional users add to the k8s aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "ingress_nginx_replica_count" {
  description = "Number of replicas for the ingress-nginx controller"
  type        = number
  default     = 2
}

variable "ingress_nginx_min_unavailable" {
  description = "Number of allowed unavaiable replicas for the ingress-nginx controller"
  type        = number
  default     = 1
}
