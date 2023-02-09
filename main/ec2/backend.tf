# BACKEND

terraform {
  backend "s3" {
    bucket         = "multi-environment-infrastructure-provisioning-state-bucket"
    key            = "ec2/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "multi-environment-infrastructure-provisioning-locktable"
    encrypt        = true
  }
}
