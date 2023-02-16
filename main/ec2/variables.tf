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

variable "autoscaling_key_name" {
  description = "The key name that should be used for the instance."
  type        = string
  default     = null
}

variable "autoscaling_ignore_desired_capacity_changes" {
  description = "Determines whether the `desired_capacity` value is ignored after initial apply."
  type        = bool
  default     = false
}

variable "autoscaling_min_size" {
  description = "The minimum size of the autoscaling group."
  type        = number
  default     = null
}

variable "autoscaling_max_size" {
  description = "The maximum size of the autoscaling group."
  type        = number
  default     = null
}

variable "autoscaling_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group."
  type        = number
  default     = null
}

variable "autoscaling_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out."
  type        = string
  default     = "10m"
}

variable "autoscaling_default_instance_warmup" {
  description = "Amount of time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics. This delay lets an instance finish initializing before Amazon EC2 Auto Scaling aggregates instance metrics, resulting in more reliable usage data. Set this value equal to the amount of time that it takes for resource consumption to become stable after an instance reaches the InService state."
  type        = number
  default     = null
}

variable "autoscaling_update_default_version" {
  description = "Whether to update Default Version each update."
  type        = bool
  default     = true # The only available value within this project.
}

variable "autoscaling_instance_type" {
  description = "The type of the instance."
  type        = string
  default     = null
}

variable "autoscaling_ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized."
  type        = bool
  default     = null
}

variable "autoscaling_enable_monitoring" {
  description = "Enables/disables detailed monitoring."
  type        = bool
  default     = true
}

variable "autoscaling_create_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile."
  type        = bool
  default     = true # The only available value within this project.
}

variable "autoscaling_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  type        = bool
  default     = true
}

variable "autoscaling_encrypted" {
  description = "Enables EBS encryption on the volume."
  type        = bool
  default     = true
}

variable "autoscaling_volume_size" {
  description = "The size of the volume in gigabytes."
  type        = number
  default     = null
}

variable "autoscaling_volume_type" {
  description = "The volume type."
  type        = string
  default     = null
}
