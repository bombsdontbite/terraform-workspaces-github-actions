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
vpc_enable_nat_gateway = true
vpc_single_nat_gateway = true

# EC2 STACK VARIABLES
