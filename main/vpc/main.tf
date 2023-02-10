# LOCALS

locals {
  tags = merge(var.tags, { "Project" = var.project, "Environment" = terraform.workspace })
}

# MODULES & RESOURCES

module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"
  providers = {
    aws = aws.target
  }
  name                               = "${terraform.workspace}-${var.project}-vpc"
  cidr                               = var.vpc_cidr
  azs                                = try(var.vpc_azs, slice(data.aws_availability_zones.target.names, 0, 3))
  public_subnets                     = var.vpc_public_subnets
  private_subnets                    = var.vpc_private_subnets
  database_subnets                   = var.vpc_database_subnets
  enable_nat_gateway                 = var.vpc_enable_nat_gateway
  single_nat_gateway                 = var.vpc_single_nat_gateway
  one_nat_gateway_per_az             = var.vpc_one_nat_gateway_per_az
  create_igw                         = var.vpc_create_igw
  map_public_ip_on_launch            = var.vpc_map_public_ip_on_launch
  enable_dns_support                 = var.vpc_enable_dns_support
  enable_dns_hostnames               = var.vpc_enable_dns_hostnames
  propagate_public_route_tables_vgw  = var.vpc_propagate_public_route_tables_vgw
  propagate_private_route_tables_vgw = var.vpc_propagate_private_route_tables_vgw
  enable_flow_log                    = var.vpc_enable_flow_log
  flow_log_destination_type          = var.vpc_flow_log_destination_type # Only s3 destination type can be used within this project.
  flow_log_destination_arn           = var.vpc_enable_flow_log && var.vpc_flow_log_destination_type == "s3" && var.vpc_flow_log_destination_arn == null ? module.s3_flow_log_bucket[0].s3_bucket_arn : var.vpc_flow_log_destination_arn
  flow_log_log_format                = var.vpc_flow_log_log_format
  flow_log_traffic_type              = var.vpc_flow_log_traffic_type
  flow_log_max_aggregation_interval  = var.vpc_flow_log_max_aggregation_interval
  tags                               = local.tags
}
  
module "http_security_group" {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group/modules/http-80"
  providers = {
    aws = aws.target
  }
  name                = "${terraform.workspace}-${var.project}-http"
  description         = "Security group with HTTP ports open for everybody (IPv4 CIDR), egress ports are all world open."
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags                = local.tags
}

# If VPC flow logs are enabled and the destination type is `s3`
# but no destination ARN has been specified,
# an S3 bucket will be created automatically and set as the flow log bucket for the VPC.
  
module "s3_flow_log_bucket" {
  count  = var.vpc_enable_flow_log && var.vpc_flow_log_destination_type == "s3" && var.vpc_flow_log_destination_arn == null ? 1 : 0 
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  providers = {
    aws = aws.target
  }
  bucket = "${terraform.workspace}-${var.project}-flow-logs-${data.aws_caller_identity.target.account_id}-${data.aws_region.target.name}"
  acl    = "log-delivery-write"
  lifecycle_rule = [
    {
      id      = "default"
      enabled = true
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 365
      }
      noncurrent_version_expiration = {
        days = 7
      }
    }
  ]
  versioning = {
    enabled = true
  }
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  force_destroy           = true
  tags                    = local.tags
}
