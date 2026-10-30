# PROVIDERS

# Management account: the credentials the workflow got through GitHub OIDC.
# The backend and terraform_remote_state use the same credentials.
provider "aws" {}

# Target account: role chaining from the management role into the environment's own account.
provider "aws" {
  alias               = "target"
  region              = var.target_region
  allowed_account_ids = [var.target_account]
  assume_role {
    role_arn     = "arn:aws:iam::${var.target_account}:role/${var.target_role}"
    session_name = "terraform-${terraform.workspace}"
  }
}
