
# Create ECR repository for the backstage image
# Source https://github.com/terraform-aws-modules/terraform-aws-ecr
module "backstage_ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6"

  repository_name                 = "backstage"
  repository_image_scan_on_push   = false
  repository_image_tag_mutability = "MUTABLE"
  create_lifecycle_policy         = false

  repository_force_delete = true
}

module "petclinic_ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 1.6"

  repository_name                 = "petclinic"
  repository_image_scan_on_push   = false
  repository_image_tag_mutability = "MUTABLE"
  create_lifecycle_policy         = false

  repository_force_delete = true
}
