# Installs the humanitec-operator into the cluster

# More details https://developer.humanitec.com/integration-and-extensions/humanitec-operator/overview/

resource "kubernetes_namespace" "humanitec_operator" {
  metadata {
    labels = {
      "app.kubernetes.io/name"     = "humanitec-operator"
      "app.kubernetes.io/instance" = "humanitec-operator"
    }

    name = "humanitec-operator"
  }
}


resource "tls_private_key" "operator_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "humanitec_key" "operator_public_key" {
  key = tls_private_key.operator_private_key.public_key_pem
}

resource "kubernetes_secret" "humanitec_operator" {
  metadata {
    name      = "humanitec-operator-private-key"
    namespace = kubernetes_namespace.humanitec_operator.id
  }

  data = {
    privateKey              = tls_private_key.operator_private_key.private_key_pem
    humanitecOrganisationID = var.humanitec_org_id
  }
}

resource "helm_release" "humanitec_operator" {
  name      = "humanitec-operator"
  namespace = kubernetes_namespace.humanitec_operator.id

  repository = "oci://ghcr.io/humanitec/charts"
  chart      = "humanitec-operator"
  version    = "0.2.4"
  wait       = true
  timeout    = 300

  depends_on = [
    humanitec_key.operator_public_key,
    kubernetes_secret.humanitec_operator
  ]
}

# Configure the operator to be able to store secrets

locals {
  humanitec_operator_k8s_sa_name = "humanitec-operator-controller-manager"
}

data "aws_iam_policy_document" "assume_role_policy" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "humanitec_operator" {
  name               = "humanitec-operator"
  description        = "Humanitec Operator EKS service account"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_eks_pod_identity_association" "humanitec_operator" {
  cluster_name    = module.aws_eks.cluster_name
  namespace       = kubernetes_namespace.humanitec_operator.id
  service_account = local.humanitec_operator_k8s_sa_name
  role_arn        = aws_iam_role.humanitec_operator.arn
}

data "aws_iam_policy_document" "humanitec_operator" {
  version = "2012-10-17"

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:PutSecretValue"
    ]

    resources = ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:*"]
  }
}

resource "aws_iam_policy" "humanitec_operator" {
  name        = "humanitec-operator"
  description = "Humanitec Operator EKS service account policy"
  policy      = data.aws_iam_policy_document.humanitec_operator.json
}

resource "aws_iam_role_policy_attachment" "humanitec_operator" {
  role       = aws_iam_role.humanitec_operator.name
  policy_arn = aws_iam_policy.humanitec_operator.arn
}


# Configure a primary secret store

locals {
  humanitec_secret_store_id = var.cluster_name
}

resource "kubectl_manifest" "humanitec_operator_secret_store" {
  yaml_body = templatefile("${path.module}/manifests/humanitec-secret-store.yaml", {
    SECRET_STORE_ID        = local.humanitec_secret_store_id,
    SECRETS_MANAGER_REGION = var.aws_region
  })
  override_namespace = kubernetes_namespace.humanitec_operator.id
  wait               = true

  depends_on = [
    helm_release.humanitec_operator
  ]
}

resource "humanitec_secretstore" "main" {
  id      = local.humanitec_secret_store_id
  primary = true
  awssm = {
    region = var.aws_region
  }
}
