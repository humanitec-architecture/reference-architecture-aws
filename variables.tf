variable "aws_account_id" {
  description = "AWS Account (ID) to use"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
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

variable "with_backstage" {
  description = "Deploy Backstage"
  type        = bool
  default     = false
}

variable "github_org_id" {
  description = "GitHub org id (required for Backstage)"
  type        = string
  default     = null
}

variable "humanitec_org_id" {
  description = "Humanitec Organization ID (required for Backstage)"
  type        = string
  default     = null
}
