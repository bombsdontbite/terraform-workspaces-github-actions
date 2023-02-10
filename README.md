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
| SECRET_PHRASE | Secret phrase to demonstrate the usage of environment secrets. | yes |

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
| vpc_flow_log_destination_type | Type of flow log destination. Can be s3 or cloud-watch-logs. **Please note: Only s3 destination type can be used within this project!**  | `string` | `"s3"` | no |
| vpc_flow_log_destination_arn | The ARN of S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. | `string` | `""` | no |
| vpc_flow_log_log_format | The fields to include in the flow log record, in the order in which they should appear. | `string` | `null` | no |
| vpc_flow_log_traffic_type | The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL. | `string` | `"ALL"` | no |
| flow_log_max_aggregation_interval | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds. | `number` | `600` | no |

### EC2 stack inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|

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
| http_security_group_id | HTTP security group ID. |

### EC2 stack outputs

| Name | Description |
|------|-------------|
