mock_provider "aws" {}

run "grants_one_role_access_to_one_secret" {
  command = plan

  variables {
    role_name  = "application-runtime"
    secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:application/database-AbCdEf"
  }

  assert {
    condition     = jsondecode(aws_iam_role_policy.secret_access.policy).Statement[0].Resource == var.secret_arn
    error_message = "The IAM policy must be scoped to the supplied secret ARN."
  }

  assert {
    condition     = toset(jsondecode(aws_iam_role_policy.secret_access.policy).Statement[0].Action) == toset(["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"])
    error_message = "The IAM policy must grant only read access to the named secret."
  }
}
