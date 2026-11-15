resource "aws_iam_role_policy" "secret_access" {
  name = "read-named-secrets-manager-secret"
  role = var.role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadNamedSecret"
      Effect   = "Allow"
      Action   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
      Resource = var.secret_arn
    }]
  })
}
