mock_provider "aws" {}

run "locks_trust_to_repository_and_ref" {
  command = apply

  variables {
    github_repository = "example/repository"
    github_ref        = "refs/heads/main"
    allowed_actions   = ["s3:GetObject"]
    resource_arns     = ["arn:aws:s3:::example-bucket/object"]
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  assert {
    condition     = strcontains(aws_iam_role.github.assume_role_policy, "repo:example/repository:ref:refs/heads/main")
    error_message = "Trust must match the configured repository and ref."
  }
}

run "rejects_wildcard_actions" {
  command = plan

  variables {
    github_repository = "example/repository"
    github_ref        = "refs/heads/main"
    allowed_actions   = ["s3:*"]
    resource_arns     = ["arn:aws:s3:::example-bucket/object"]
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  expect_failures = [var.allowed_actions]
}

run "rejects_wildcard_resources" {
  command = plan

  variables {
    github_repository = "example/repository"
    github_ref        = "refs/heads/main"
    allowed_actions   = ["s3:GetObject"]
    resource_arns     = ["*"]
    tags = {
      Environment = "test"
      Owner       = "siiick-brain"
      Project     = "kiln-infra-factory"
    }
  }

  expect_failures = [var.resource_arns]
}
