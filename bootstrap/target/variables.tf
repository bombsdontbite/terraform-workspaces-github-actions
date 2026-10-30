# VARIABLES

variable "region" {
  description = "Any region: IAM is global, the provider just needs one."
  type        = string
  default     = "eu-north-1"
}

variable "management_role_arns" {
  description = "The management-account roles (bootstrap/management output `environment_role_arns`) of the environments that deploy into this account."
  type        = list(string)
}

variable "role_name" {
  description = "Name of the role Terraform assumes here; the TARGET_ROLE variable of the environment."
  type        = string
  default     = "terraform-target"
}

variable "managed_policy_arns" {
  description = "AWS managed policies for the role. PowerUserAccess covers everything but IAM; the IAM the stacks need is granted below."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

variable "tags" {
  description = "Tags for every resource."
  type        = map(string)
  default = {
    "Provisioner" = "Terraform"
    "Stack"       = "bootstrap/target"
  }
}
