# Multi-environment infrastructure provisioning using Terraform Workspaces &amp; GitHub Actions

## Description

-----

## Environments

| Name | Desctiption | 
|------|------|
| dev | Development environment. |
| stag | Staging environment. |
| prod | Production environment. |

-----

## Secrets

### Repository secrets

| Secret name | Desctiption | Required |
|------|------|------|
| AWS_ACCESS_KEY_ID | Specifies an AWS access key associated with an IAM user. | yes |
| AWS_SECRET_ACCESS_KEY | Specifies the secret key associated with the access key. This is essentially the "password" for the access key. | yes |
| AWS_DEFAULT_REGION | Specifies the AWS Region to send the request to. | yes |

### Environment secrets

| Secret name | Desctiption | Required |
|------|------|------|
| SECRET_PHRASE | Secret phrase to demonstrate the usage of environment secrets . | yes |

-----

## Inputs

### Common variables

### VPC stack variables

### EC2 stack variables
