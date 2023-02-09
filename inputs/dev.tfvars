# COMMON VARIABLES

target_account = "757382187207"

target_region = "eu-north-1"

target_role = "MyTerraformRole"

project = "awesome-project"

tags = {
  "Provisioner" = "Terraform"
  "Owner"       = "Kirill Ushkalov"
}

# VPC STACK VARIABLES

vpc_cidr = "10.0.0.0/16"

vpc_public_subnets = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]

# EC2 STACK VARIABLES
