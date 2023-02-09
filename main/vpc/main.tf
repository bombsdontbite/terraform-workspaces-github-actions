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
  name                    = "${terraform.workspace}-${var.project}-vpc"
  cidr                    = var.vpc_cidr
  azs                     = try(var.vpc_azs, slice(data.aws_availability_zones.target.names, 0, 3))
  public_subnets          = var.vpc_public_subnets
  map_public_ip_on_launch = var.vpc_map_public_ip_on_launch
  tags                    = local.tags
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
