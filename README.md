# Multi-environment infrastructure provisioning using Terraform Workspaces &amp; GitHub Actions

## Description

This project demonstrates the potential of reusable workflows using GitHub Actions to provision multi-environment AWS infrastructure. You can read more about this project in [my article on Medium](http://example.com/).

> **Please note:**  I'm not focusing on infrastructure security in terms of AWS best practices and recommendations, this project is just a demonstration of GitHub Actions features. 

-----

## Environments

| Name | Desctiption | 
|------|-------------|
| dev | Development environment. |
| stag | Staging environment. |
| prod | Production environment. |

-----

## Secrets

### Repository secrets

| Secret name | Desctiption | Required |
|-------------|-------------|----------|
| AWS_ACCESS_KEY_ID | Specifies an AWS access key associated with an IAM user. | yes |
| AWS_SECRET_ACCESS_KEY | Specifies the secret key associated with the access key. This is essentially the "password" for the access key. | yes |
| AWS_DEFAULT_REGION | Specifies the AWS Region to send the request to. | yes |

### Environment secrets

| Secret name | Desctiption | Required |
|-------------|-------------|----------|
| TARGET_ACCOUNT | Target AWS account ID. | yes |
| TARGET_REGION | Target AWS region name. | yes |
| TARGET_ROLE | Target AM role to be assumed. | yes |

-----

## Inputs

### Common inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| target_account | Target AWS account ID. | `string` | `null` | yes (auto-filled) |
| target_region | Target AWS region name. | `string` | `null` | yes (auto-filled) |
| target_role | Target AWS IAM role name to be assumed. | `string` | `null` | yes (auto-filled) |
| project | Project name. | `string` | `null` | yes |
| tags | A map of tags to assign to the resources. | `map(string)` | `{}` | no |

### VPC stack inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_cidr | The IPv4 CIDR block for the VPC. | `string` | `null` | yes |
| vpc_azs | A list of availability zones names or IDs in the target region. | `list(string)` | `[]` | no |
| vpc_public_subnets | A list of public subnets CIDR bloks inside the VPC. | `list(string)` | `[]` | no |
| vpc_private_subnets | A list of private subnets CIDR bloks inside the VPC. | `list(string)` | `[]` | no |
| vpc_database_subnets | A list of database subnets CIDR bloks inside the VPC. | `list(string)` | `[]` | no |
| vpc_enable_nat_gateway | Should be true if you want to provision NAT Gateways for each of your private networks. | `bool` | `false` | no |
| vpc_single_nat_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks. | `bool` | `false` | no |
| vpc_one_nat_gateway_per_az | Should be true if you want only one NAT Gateway per availability zone. Requires the number of `vpc_public_subnets` created to be greater than or equal to the number of availability zones. | `bool` | `false` | no |
| vpc_create_igw | Controls if an Internet Gateway is created for public subnets and the related routes that connect them. | `bool` | `true` | no |
| vpc_map_public_ip_on_launch | Should be false if you do not want to auto-assign public IP on launch. | `bool` | `false` | no |
| vpc_enable_dns_support | Should be true to enable DNS support in the VPC. | `bool` | `true` | no |
| vpc_enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC. | `bool` | `false` | no |
| vpc_propagate_public_route_tables_vgw | Should be true if you want route table propagation. | `bool` | `false` | no |
| vpc_propagate_private_route_tables_vgw | Should be true if you want route table propagation. | `bool` | `false` | no |
| vpc_enable_flow_log | Whether or not to enable VPC Flow Logs. | `bool` | `false` | no |
| vpc_flow_log_destination_type | Type of flow log destination. Can be s3 or cloud-watch-logs. **Please note: Only `s3` destination type can be used within this project!**  | `string` | `"s3"` | no |
| vpc_flow_log_destination_arn | The ARN of S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. | `string` | `null` | no |
| vpc_flow_log_log_format | The fields to include in the flow log record, in the order in which they should appear. | `string` | `null` | no |
| vpc_flow_log_traffic_type | The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL. | `string` | `"ALL"` | no |
| flow_log_max_aggregation_interval | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds. | `number` | `600` | no |

### EC2 stack inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| alb_load_balancer_type | The type of load balancer to create. Possible values are application or network. **Please note: Only `"application"` loadbalancer type can be used within this project!** | `string` | `"application"` | no |
| alb_internal | Boolean determining if the load balancer is internal or externally facing. | `bool` | `false` | no |
| alb_idle_timeout | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| alb_load_balancer_create_timeout | Timeout value when creating the ALB. | `string` | `"10m"` | no |
| alb_load_balancer_update_timeout | Timeout value when updating the ALB. | `string` | `"10m"` | no |
| alb_load_balancer_delete_timeout | Timeout value when deleting the ALB. | `string` | `"10m"` | no |
| autoscaling_key_name | The key name that should be used for the instance. | `string` | `null` | no |
| autoscaling_ignore_desired_capacity_changes | Determines whether the `desired_capacity` value is ignored after initial apply. | `bool` | `false` | no |
| autoscaling_min_size | The minimum size of the autoscaling group. | `number` | `null` | no |
| autoscaling_max_size | The maximum size of the autoscaling group. | `number` | `null` | no |
| autoscaling_desired_capacity | The number of Amazon EC2 instances that should be running in the autoscaling group. | `number` | `null` | no |
| autoscaling_wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. | `string` | `"10m"` | no |
| autoscaling_default_instance_warmup | Amount of time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics. This delay lets an instance finish initializing before Amazon EC2 Auto Scaling aggregates instance metrics, resulting in more reliable usage data. Set this value equal to the amount of time that it takes for resource consumption to become stable after an instance reaches the InService state. | `number` | `null` | no |
| autoscaling_update_default_version | Whether to update Default Version each update. **Please note: Only the `true` value available value within this project!** | `bool` | `true` | no |
| autoscaling_instance_type | The type of the instance. | `string` | `null` | no |
| autoscaling_ebs_optimized | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `null` | no |
| autoscaling_enable_monitoring | Enables/disables detailed monitoring. | `bool` | `true` | no |
| autoscaling_create_iam_instance_profile | Determines whether an IAM instance profile is created or to use an existing IAM instance profile. **Please note: Only the `true` value available value within this project!** | `bool` | `true` | no |
| autoscaling_delete_on_termination | Whether the volume should be destroyed on instance termination. | `bool` | `true` | no |
| autoscaling_encrypted | Enables EBS encryption on the volume. | `bool` | `true` | no |
| autoscaling_volume_size | The size of the root volume in gigabytes. | `number` | `null` | no |
| autoscaling_volume_type | The root volume type. | `string` | `null` | no |

-----

## Outputs

### VPC stack outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC. |
| vpc_cidr_block | The CIDR block of the VPC. |
| private_subnets | List of IDs of private subnets. |
| private_subnets_cidr | List of CIDR blocks of private subnets. |
| public_subnets | List of IDs of public subnets. |
| public_subnets_cidr | List of CIDR blocks of public subnets. |
| database_subnets | List of IDs of database subnets. |
| database_subnets_cidr | List of CIDR blocks of database subnets. |
| database_subnet_group | ID of database subnet group. |
| natgw_ids | List of NAT Gateway IDs. |
| nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway. |
| igw_id | The ID of the Internet Gateway. |
| s3_flow_log_bucket_name | The name of the flow-log bucket. |
| s3_flow_log_bucket_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |

### EC2 stack outputs

| Name | Description |
|------|-------------|
| alb_dns_name | The DNS name of the load balancer. |
