# Multi-environment infrastructure provisioning using Terraform Workspaces &amp; GitHub Actions

## Description

This project demonstrates the potential of reusable workflows using GitHub Actions to provision multi-environment AWS infrastructure. You can read more about this project in [my article on Medium](http://example.com/).

> **Please note!**  I'm not focusing on infrastructure security in terms of AWS best practices and recommendations, this project is just a demonstration of GitHub Actions features. 

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

### Common variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| target_account | Target AWS account ID. | `string` | `null` | yes |
| target_region | Target AWS region name. | `string` | `null` | yes |
| target_role | Target AWS IAM role name to be assumed. | `string` | `null` | yes |
| project | Project name. | `string` | `null` | yes |
| tags | A map of tags to assign to the resources. | `map(string)` | `{}` | no |

### VPC stack variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_cidr | The IPv4 CIDR block for the VPC. | `string` | `null` | yes |
| vpc_azs | A list of availability zones names or IDs in the target region. | `list(string)` | `[]` | no |
| vpc_public_subnets | A list of public subnets CIDR bloks inside the VPC. | `list(string)` | `null` | yes |
| vpc_map_public_ip_on_launch | Should be false if you do not want to auto-assign public IP on launch. | `bool` | `false` | no |

### EC2 stack variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
