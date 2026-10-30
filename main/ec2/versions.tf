# VERSIONS

terraform {
  required_version = "~> 1.17" # CI runs exactly 1.17.1 (setup-terraform); S3 native locking needs >= 1.11.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
  }
}
