resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  tags           = var.tags
}

resource "aws_iam_role" "github" {
  name = "github-${replace(var.github_repository, "/", "-")}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:ref:${var.github_ref}"
        }
      }
    }]
  })
  tags = merge(var.tags, { Name = "github-${replace(var.github_repository, "/", "-")}" })
}

resource "aws_iam_role_policy" "github" {
  name = "scoped-actions"
  role = aws_iam_role.github.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = sort(tolist(var.allowed_actions))
      Resource = sort(tolist(var.resource_arns))
    }]
  })
}
