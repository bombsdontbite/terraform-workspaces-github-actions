# VARIABLES

variable "region" {
  description = "Region of the state bucket. Must match `region` in main/*/backend.tf."
  type        = string
  default     = "eu-north-1"
}

variable "state_bucket_name" {
  description = "Name of the Terraform state bucket. Must match `bucket` in main/*/backend.tf."
  type        = string
  default     = "multi-environment-infrastructure-provisioning-state-bucket"
}

variable "workspace_key_prefix" {
  description = "Must match `workspace_key_prefix` in main/*/backend.tf."
  type        = string
  default     = "workspaces"
}

variable "stacks" {
  description = "Stack directories under main/. Their backend `key` is `<stack>/terraform.tfstate`."
  type        = list(string)
  default     = ["vpc", "ec2"]
}

variable "github_subject_prefix" {
  description = "The `sub` claim prefix GitHub issues for the repository: `gh api repos/<owner>/<repo>/actions/oidc/customization/sub` prints it as `sub_claim_prefix`."
  type        = string
  default     = "repo:bombsdontbite/terraform-workspaces-github-actions"
}

variable "environments" {
  description = "GitHub environment name => the AWS account its resources live in."
  type = map(object({
    target_account_id = string
  }))
}

variable "target_role_name" {
  description = "Name of the role bootstrap/target creates in each target account."
  type        = string
  default     = "terraform-target"
}

variable "create_oidc_provider" {
  description = "An account holds one GitHub OIDC provider; set false if it already exists."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for every resource."
  type        = map(string)
  default = {
    "Provisioner" = "Terraform"
    "Stack"       = "bootstrap/management"
  }
}
