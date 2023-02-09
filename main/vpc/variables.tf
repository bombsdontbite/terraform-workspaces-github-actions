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

variable "vpc_private_subnets" {
  description = "A list of private subnets CIDR bloks inside the VPC."
  type        = list(string)
  default     = []
}

variable "vpc_database_subnets" {
  description = "A list of database subnets CIDR bloks inside the VPC."
  type        = list(string)
  default     = []
}

variable "vpc_enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks."
  type        = bool
  default     = false
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks."
  type        = bool
  default     = false
}

variable "vpc_one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires the number of `vpc_public_subnets` created to be greater than or equal to the number of availability zones."
  type        = bool
  default     = false
}

variable "vpc_create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them."
  type        = bool
  default     = true
}

variable "vpc_map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch."
  type        = bool
  default     = false
}

variable "vpc_enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC."
  type        = bool
  default     = false
}

variable "vpc_propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation."
  type        = bool
  default     = false
}

variable "vpc_propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation."
  type        = bool
  default     = false
}

variable "vpc_enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "vpc_flow_log_destination_type" {
  description = "Type of flow log destination. Can be s3 or cloud-watch-logs." # Only s3 destination type can be used within this project.
  type        = string
  default     = "s3"
}

variable "vpc_flow_log_destination_arn" {
  description = "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided."
  type        = string
  default     = ""
}

variable "vpc_flow_log_log_format" {
  description = "The fields to include in the flow log record, in the order in which they should appear."
  type        = string
  default     = null
}

variable "vpc_flow_log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
  type        = string
  default     = "ALL"
}

variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds."
  type        = number
  default     = 600
}
