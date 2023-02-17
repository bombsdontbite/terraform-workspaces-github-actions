# COMMON VARIABLES

project = "awesome-project"

tags = {
  "Provisioner" = "Terraform"
  "Owner"       = "Not your typical DevOps"
}

# VPC STACK VARIABLES

vpc_cidr               = "10.0.0.0/16"
vpc_public_subnets     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
vpc_private_subnets    = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
vpc_database_subnets   = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20"]
vpc_enable_nat_gateway = true
vpc_enable_flow_log    = true

# EC2 STACK VARIABLES

autoscaling_ignore_desired_capacity_changes = true
autoscaling_min_size                        = 2
autoscaling_max_size                        = 5
autoscaling_desired_capacity                = 3
autoscaling_default_instance_warmup         = 300
autoscaling_instance_type                   = "t3.medium"
autoscaling_ebs_optimized                   = true
autoscaling_volume_size                     = 16
autoscaling_volume_type                     = "gp3"
