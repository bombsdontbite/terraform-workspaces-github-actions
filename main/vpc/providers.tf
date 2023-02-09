# PROVIDERS

provider "aws" {}

provider "aws" {
  alias  = "target"
  region = var.target_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.target_account}:role/${var.target_role}"
    session_name = "terraform"
  }
}
