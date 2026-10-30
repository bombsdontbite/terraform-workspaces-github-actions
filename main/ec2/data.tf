# DATA

data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket               = "multi-environment-infrastructure-provisioning-state-bucket"
    key                  = "vpc/terraform.tfstate"
    workspace_key_prefix = "workspaces"
    region               = "eu-north-1" # The state bucket's region.
  }
}

# Amazon Linux 2 reached end of support on 2026-06-30; Amazon Linux 2023 replaces it.
data "aws_ami" "amazon_linux" {
  provider    = aws.target
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
