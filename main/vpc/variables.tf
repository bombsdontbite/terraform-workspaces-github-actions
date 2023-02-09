# COMMON VARIABLES

variable "target_account" {
  description = "Target AWS account ID."
  type        = string
  default     = null
}

variable "target_region" {
  description = "Target AWS region name."
  type        = string
  default     = null
}

variable "target_role" {
  description = "Target AWS IAM role name to be assumed."
  type        = string
  default     = null
}

variable "project" {
  description = "Project name."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

# STACK VARIABLES

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = null
}

variable "vpc_azs" {
  description = "A list of availability zones names or IDs in the target region."
  type        = list(string)
  default     = []
}

variable "vpc_public_subnets" {
  description = "A list of public subnets CIDR bloks inside the VPC."
  type        = list(string)
  default     = []
}

variable "vpc_map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch."
  type        = bool
  default     = false
}
