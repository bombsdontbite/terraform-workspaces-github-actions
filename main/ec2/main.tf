# LOCALS

locals {
  tags = merge(var.tags, { "Project" = var.project, "Environment" = terraform.workspace })
}

# MODULES & RESOURCES

module "alb_security_group" {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group/modules/http-80"
  providers = {
    aws = aws.target
  }
  name                = "${terraform.workspace}-${var.project}-http"
  use_name_prefix     = false
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  tags                = local.tags
}

module "autoscaling_security_group" {
  source  = "github.com/terraform-aws-modules/terraform-aws-security-group/"
  providers = {
    aws = aws.target
  }
  name            = "${terraform.workspace}-${var.project}-autoscaling"
  use_name_prefix = false
  vpc_id          = module.vpc.vpc_id
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_security_group.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  egress_rules                                             = ["all-all"]
  tags                                                     = local.tags
}

module "alb" {
  source = "github.com/terraform-aws-modules/terraform-aws-alb"
  providers = {
    aws = aws.target
  }
  name                           = "${terraform.workspace}-${var.project}-lb"
  load_balancer_type             = var.alb_load_balancer_type # Only application loadbalancer type can be used within this project.
  internal                       = var.alb_internal
  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets                        = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups                = [module.alb_security_group.security_group_id]
  security_group_use_name_prefix = false
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
  idle_timeout                 = var.alb_idle_timeout
  load_balancer_create_timeout = var.alb_load_balancer_create_timeout
  load_balancer_update_timeout = var.alb_load_balancer_update_timeout
  load_balancer_delete_timeout = var.alb_load_balancer_delete_timeout
  tags                         = local.tags
}

module "autoscaling" {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling"
  providers = {
    aws = aws.target
  }
  name                            = "${terraform.workspace}-${var.project}-autoscaling"
  use_name_prefix                 = false
  instance_name                   = "${terraform.workspace}-${var.project}-web-server"
  key_name                        = var.autoscaling_key_name
  ignore_desired_capacity_changes = var.autoscaling_ignore_desired_capacity_changes
  min_size                        = var.autoscaling_min_size
  max_size                        = var.autoscaling_max_size
  desired_capacity                = var.autoscaling_desired_capacity
  wait_for_capacity_timeout       = var.autoscaling_wait_for_capacity_timeout
  default_instance_warmup         = var.autoscaling_default_instance_warmup
  health_check_type               = "EC2"
  vpc_zone_identifier             = data.terraform_remote_state.vpc.outputs.private_subnets
  service_linked_role_arn         = aws_iam_service_linked_role.this.arn
  launch_template_name            = "${terraform.workspace}-${var.project}-launch-template"
  update_default_version          = var.autoscaling_update_default_version
  image_id                        = data.aws_ami.amazon_linux.id
  instance_type                   = var.autoscaling_instance_type
  user_data                       = base64encode(templatefile("../../templates/user_data.sh.tpl", { secret_phrase = "Hello from ${upper(terraform.workspace)} environment!" }))
  ebs_optimized                   = var.autoscaling_ebs_optimized
  enable_monitoring               = var.autoscaling_enable_monitoring
  create_iam_instance_profile     = var.autoscaling_create_iam_instance_profile
  iam_role_name                   = "${terraform.workspace}-${var.project}-web-server-role"
  iam_role_path                   = "/ec2/"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  security_groups   = [module.autoscaling_security_group.security_group_id]
  target_group_arns = module.alb.target_group_arns
  block_device_mappings = [
    {
      # Root volume only
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = var.autoscaling_delete_on_termination
        encrypted             = var.autoscaling_encrypted
        volume_size           = var.autoscaling_volume_size
        volume_type           = var.autoscaling_volume_type
      }
    }
  ]
  scaling_policies = {
    cpu-autoscaling = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 1200
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value       = 70.0
        scale_in_cooldown  = 300
        scale_out_cooldown = 300
      }
    }
  }
  tags = local.tags
}
  
# SUPPORTING RESOURCES
  
resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling."
  custom_suffix    = "${terraform.workspace}-${var.project}"
  provisioner "local-exec" {
    command = "sleep 10"
  }
}
