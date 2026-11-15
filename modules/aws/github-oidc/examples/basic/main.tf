module "github_oidc" {
  source = "../.."

  github_repository = "example/repository"
  github_ref        = "refs/heads/main"
  allowed_actions   = ["s3:GetObject"]
  resource_arns     = ["arn:aws:s3:::example-bucket/object"]
  tags = {
    Environment = "dev"
    Owner       = "siiick-brain"
    Project     = "kiln-infra-factory"
  }
}
