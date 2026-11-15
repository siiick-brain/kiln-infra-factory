provider "aws" {
  region                      = "us-east-1"
  access_key                  = "testing"
  secret_key                  = "testing"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    secretsmanager = "http://localhost:5000"
    iam            = "http://localhost:5000"
  }
}

module "secret_access" {
  source = "../.."

  role_name  = "application-runtime"
  secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:application/database-AbCdEf"
}
