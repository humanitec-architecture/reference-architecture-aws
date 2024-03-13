resource "aws_iam_user" "konstantin_bauer" {
  name = "konstantin.bauer"
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr_policy"
  description = "ECR policy for read, pull, and get"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECRReadPullGet",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:GetRepositoryScanFindings",
        "ecr:DescribeRepositories",
        "ecr:DescribeImageScanFindings",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "konstantin_bauer_policy_attachment" {
  user       = aws_iam_user.konstantin_bauer.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}
