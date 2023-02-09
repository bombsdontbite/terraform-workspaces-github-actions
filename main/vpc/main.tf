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
  enable_flow_log                    = var.vpc_enable_flow_log
  flow_log_destination_type          = var.vpc_flow_log_destination_type
  flow_log_destination_arn           = var.vpc_enable_flow_log && var.vpc_flow_log_destination_type == "s3" && var.vpc_flow_log_destination_arn == null ? module.s3_flow_log_bucket[0].s3_bucket_arn : var.vpc_flow_log_destination_arn
  propagate_public_route_tables_vgw  = var.vpc["propagate_public_route_tables_vgw"]
  propagate_private_route_tables_vgw = var.vpc["propagate_private_route_tables_vgw"]
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
