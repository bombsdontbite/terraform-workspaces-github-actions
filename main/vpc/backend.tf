# BACKEND

terraform {
  backend "s3" {
    bucket         = "multi-environment-infrastructure-provisioning-state-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "multi-environment-infrastructure-provisioning-locktable"
    encrypt        = true
  }
}