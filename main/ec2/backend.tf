# BACKEND

terraform {
  backend "s3" {
    bucket = "multi-environment-infrastructure-provisioning-state-bucket"
    key    = "ec2/terraform.tfstate"
    # Each workspace's state lives at workspaces/<workspace>/ec2/terraform.tfstate,
    # so an environment's role can be limited to its own prefix.
    workspace_key_prefix = "workspaces"
    region               = "eu-north-1" # The state bucket's region, not the target environment's.
    use_lockfile         = true         # Native S3 locking (Terraform >= 1.11): no DynamoDB table.
    encrypt              = true
  }
}
