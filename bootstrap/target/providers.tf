# PROVIDERS

# Applied once by a person with administrator credentials for this account.
# State stays local: this stack creates what the remote state needs.
provider "aws" {
  region = var.region
}
