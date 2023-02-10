# COMMON VARIABLES

variable "target_account" {
  description = "Target AWS account ID."
  sensitive   = true
  type        = string
  default     = null
}

variable "target_region" {
  description = "Target AWS region name."
  sensitive   = true
  type        = string
  default     = null
}

variable "target_role" {
  description = "Target AWS IAM role name to be assumed."
  sensitive   = true
  type        = string
  default     = null
}

variable "project" {
  description = "Project name."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to be assigned to the resources."
  type        = map(string)
  default     = {}
}

# STACK VARIABLES

variable "alb_load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network." # Only application loadbalancer type can be used within this project.
  type        = string
  default     = "application"
}

variable "alb_internal" {
  description = "Boolean determining if the load balancer is internal or externally facing."
  type        = bool
  default     = false
}

variable "alb_enable_cross_zone_load_balancing" {
  description = "Indicates whether cross zone load balancing should be enabled in application load balancers."
  type        = bool
  default     = false
}

variable "alb_idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60
}

variable "alb_load_balancer_create_timeout" {
  description = "Timeout value when creating the ALB."
  type        = string
  default     = "10m"
}

variable "alb_load_balancer_update_timeout" {
  description = "Timeout value when updating the ALB."
  type        = string
  default     = "10m"
}

variable "alb_load_balancer_delete_timeout" {
  description = "Timeout value when deleting the ALB."
  type        = string
  default     = "10m"
}
