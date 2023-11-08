
variable "aws_region" {
  description = "AWS Region to deploy into"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account (ID) to use"
  type        = string
}

variable "humanitec_org_id" {
  description = "Humanitec Organization ID"
  type        = string
}

variable "instance_types" {
  description = "List of EC2 instances types to use for EKS nodes"
  type        = list(string)
  default = [
    "t3.large"
  ]
}
