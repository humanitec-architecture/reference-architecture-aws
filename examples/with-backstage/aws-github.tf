locals {
  name           = "gha-ecr-push"
  cloud_provider = "aws"
}

# Create a role for GitHub Actions to push to ECR using OpenID Connect (OIDC) so we don't need to store AWS credentials in GitHub
# Reference https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

# Source https://github.com/terraform-aws-modules/terraform-aws-iam
module "iam_github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "~> 5.30"
}

module "iam_github_oidc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> 5.30"

  name = local.name

  subjects = [
    "${var.github_org_id}/*",
  ]

  policies = {
    ecr_push_policy = aws_iam_policy.ecr_push_policy.arn
  }
}

# Reference https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-push.html#image-push-iam
resource "aws_iam_policy" "ecr_push_policy" {
  name        = local.name
  description = "GitHub Actions ECR Push Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
