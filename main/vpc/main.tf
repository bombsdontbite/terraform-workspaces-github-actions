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
  name           = "${terraform.workspace}-${var.project}-vpc"
  cidr           = var.vpc_cidr
  azs            = try(var.vpc_azs, slice(data.aws_availability_zones.target.names, 0, 3))
  public_subnets = var.vpc_public_subnets
  tags           = local.tags
}
