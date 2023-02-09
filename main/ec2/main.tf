# LOCALS

locals {
  tags = merge(var.tags, { "Project" = var.project, "Environment" = terraform.workspace })
}

# MODULES & RESOURCES

module "alb" {
  source = "github.com/terraform-aws-modules/terraform-aws-alb"
  providers = {
    aws = aws.target
  }
  # tbd
}

module "autoscaling" {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling"
  providers = {
    aws = aws.target
  }
  # tbd
}
