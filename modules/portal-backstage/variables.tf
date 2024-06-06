variable "humanitec_org_id" {
  description = "Humanitec Organization ID"
  type        = string
}

variable "humanitec_ci_service_user_token" {
  description = "Humanitec CI Service User Token"
  type        = string
  sensitive   = true
}

variable "github_org_id" {
  description = "GitHub org id"
  type        = string
}

variable "github_app_client_id" {
  description = "GitHub App Client ID"
  type        = string
}

variable "github_app_client_secret" {
  description = "GitHub App Client Secret"
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_webhook_secret" {
  description = "GitHub Webhook Secret"
  type        = string
}

variable "github_app_private_key" {
  description = "GitHub App Private Key"
  type        = string
}
