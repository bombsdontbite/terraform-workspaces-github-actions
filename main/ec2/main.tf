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
  name            = "${terraform.workspace}-${var.project}-lb"
  internal        = var.alb_internal
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups = [data.terraform_remote_state.vpc.outputs.http_security_group_id]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  target_groups = [
    {
      name             = "${terraform.workspace}-${var.project}-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
  tags = local.tags
}

module "autoscaling" {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling"
  providers = {
    aws = aws.target
  }
  # tbd
}
