# DATA

data "terraform_remote_state" "aws_network" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "multi-environment-infrastructure-provisioning-state-bucket"
    key    = "vpc/terraform.tfstate"
    region = "eu-north-1"
  }
}
