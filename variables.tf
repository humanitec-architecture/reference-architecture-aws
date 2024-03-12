variable "aws_account_id" {
  description = "AWS Account (ID) to use"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "github_org_id" {
  description = "GitHub org id"
  type        = string
}

variable "github_app_credentials" {
  description = "base64 encodece string of the GitHub App credentials file"
  type = string
}

variable "humanitec_org_id" {
  description = "Humanitec Organization ID"
  type        = string
}

variable "humanitec_ci_service_user_token" {
  description = "Humanitec CI Service User Token"
  type        = string
  sensitive   = true
}

variable "resource_packs_aws_rev" {
  description = "Revision of the resource-packs-aws repository to use"
  type        = string
  default     = "refs/heads/main"
}

variable "instance_types" {
  description = "List of EC2 instances types to use for EKS nodes"
  type        = list(string)
  default = [
    "t3.large"
  ]
}

variable "disk_size" {
  description = "Disk size in GB to use for EKS nodes"
  type        = number
  default     = 20
}
