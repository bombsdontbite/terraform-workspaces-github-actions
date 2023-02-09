# OUTPUTS

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets."
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr" {
  description = "List of CIDR blocks of private subnets."
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
  description = "List of IDs of public subnets."
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr" {
  description = "List of CIDR blocks of public subnets."
  value       = module.vpc.public_subnets_cidr_blocks
}

output "database_subnets" {
  description = "List of IDs of database subnets."
  value       = module.vpc.database_subnets
}

output "database_subnets_cidr" {
  description = "List of CIDR blocks of database subnets."
  value       = module.vpc.database_subnets_cidr_blocks
}

output "database_subnet_group" {
  description = "ID of database subnet group."
  value       = module.vpc.database_subnet_group
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs."
  value       = module.vpc.natgw_ids
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway."
  value       = module.vpc.nat_public_ips
}
  
output "igw_id" {
  description = "The ID of the Internet Gateway."
  value       = module.vpc.igw_id
}

output "s3_flow_log_bucket_name" {
  description = "The name of the flow-log bucket."
  value       = try(module.s3_flow_log_bucket[0].s3_bucket_id, "")
}

output "s3_flow_log_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = try(module.s3_flow_log_bucket[0].s3_bucket_arn, "")
}
  
output "http_security_group_id" {
  description = "HTTP security group ID."
  value       = module.http_security_group.security_group_id
}
