# Multi-environment infrastructure provisioning using Terraform Workspaces &amp; GitHub Actions

## Description

This project demonstrates reusable GitHub Actions workflows that provision the same AWS infrastructure into several environments: one code base, one set of inputs per environment, one Terraform CLI workspace per environment. You can read more about it in [my article on Medium](https://medium.com/@bombsdontbite/multi-environment-infrastructure-provisioning-using-terraform-workspaces-github-actions-bb898330b6e).

The article was written in March 2023. The code was brought up to date in October 2026; [what changed since 2023](#what-changed-since-2023) lists the differences.

> **Please note:** this is still a demonstration of GitHub Actions and Terraform features, not a production blueprint. For example, the load balancer serves plain HTTP to the internet, because HTTPS needs a domain and a certificate.

-----

## How it works

```
inputs/{dev,stag,prod}.tfvars ──┐
                                ├─► main/vpc ──(terraform_remote_state, same workspace)──► main/ec2
terraform workspace <env> ──────┘
```

- **Two stacks**, `main/vpc` and `main/ec2`, built from [terraform-aws-modules](https://github.com/terraform-aws-modules). The EC2 stack reads the VPC stack's outputs with `terraform_remote_state` and `workspace = terraform.workspace`, so `dev` reads `dev`.
- **One workspace per environment.** The S3 backend keeps each workspace's state at `workspaces/<env>/<stack>/terraform.tfstate` and locks it with a `.tflock` object beside it (`use_lockfile`, no DynamoDB).
- **Two providers.** The default `aws` provider is the management account, where the state lives; the workflow reaches it through GitHub OIDC. The `target` alias assumes a role in the environment's own account (role chaining), and every resource uses it.
- **One reusable workflow**, `terraform-stack.yml`, takes an environment, a stack and a mode (`plan`, `apply`, `destroy`). `apply-all.yml` and `destroy-all.yml` call it for both stacks in order. `pull-request.yml` only runs checks and never touches AWS.

-----

## Setup

Nothing here creates AWS resources until you apply it. The bootstrap is applied once, by hand, with administrator credentials; its state stays local (keep it somewhere safe, or move it into the bucket afterwards with a `backend "s3"` block and `terraform init -migrate-state`).

### 1. Management account: OIDC provider, state bucket, one role per environment

```bash
cd bootstrap/management
cp terraform.tfvars.example terraform.tfvars   # put in the target account IDs
gh api repos/<owner>/<repo>/actions/oidc/customization/sub   # check sub_claim_prefix
terraform init && terraform apply
```

Each role `github-terraform-<env>` trusts only a job of this repository running in GitHub environment `<env>`: the token's `sub` must equal `repo:<owner>/<repo>:environment:<env>` and its `aud` `sts.amazonaws.com`. If GitHub issues the repository an immutable subject (`use_immutable_subject: true` in the call above, with ids in the prefix), set `github_subject_prefix` to the `sub_claim_prefix` it prints. A role may read and write only `workspaces/<env>/*` in the state bucket, delete only its own `.tflock` objects, and assume only `<env>`'s target role.

If the account already has a GitHub OIDC provider, set `create_oidc_provider = false`. If you change the bucket name, region or `workspace_key_prefix`, change them in `main/*/backend.tf` and `main/ec2/data.tf` as well; backend blocks cannot take variables.

### 2. Each target account: the role Terraform works in

```bash
cd bootstrap/target
cp terraform.tfvars.example terraform.tfvars   # the management role ARNs from step 1
terraform init && terraform apply              # with that account's administrator credentials
```

The role `terraform-target` trusts the management roles of the environments that deploy into the account. It has `PowerUserAccess` plus the IAM the stacks create (the web servers' role under `/ec2/` and the Auto Scaling service-linked role). The chained session lasts at most an hour, which bounds a single apply.

### 3. GitHub environments

Create `dev`, `stag` and `prod` (*Settings → Environments*) and give each these **environment variables**. Nothing in them is a credential, so they are variables, not secrets; if you would rather hide the account IDs, store them as environment secrets and read `secrets.` instead of `vars.` in `terraform-stack.yml`.

| Variable | Value |
|----------|-------|
| `AWS_ROLE_ARN` | `github-terraform-<env>` from step 1 (output `environment_role_arns`). |
| `AWS_REGION` | The state bucket's region (`eu-north-1`). |
| `TARGET_ACCOUNT` | The environment's AWS account ID. |
| `TARGET_REGION` | The region its resources go to. |
| `TARGET_ROLE` | `terraform-target`. |

Protection rules:

| Environment | Required reviewers | Deployment branches |
|-------------|--------------------|---------------------|
| `dev` | yes | all branches, for manual runs from a feature branch |
| `stag` | yes | `main` only |
| `prod` | yes, and prevent self-review | `main` only |

The plan and the apply are separate jobs and both run in the environment, so in every environment a reviewer approves twice: once to let the plan run, then again after reading it in the run's summary. Because `dev` accepts any branch, anyone who can push a branch can use the `dev` role from it; keep `dev` a sandbox in its own account.

### 4. First run

Run **apply-all** for `dev` once to check the whole setup end to end. The EC2 stack reads the VPC stack's applied state, so `apply-all` applies `vpc` first.

-----

## Running

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `pull-request` | pull request to `main` | `terraform fmt -check`, `init -backend=false` and `validate` for every root module, Trivy (fails on HIGH/CRITICAL, results in *Security → Code scanning*). It needs no AWS access. |
| `terraform-stack` | manual, or called | Plans one stack in one environment; in `apply` or `destroy` mode a second job applies that exact plan. |
| `apply-all` | manual | `vpc`, then `ec2`. |
| `destroy-all` | manual | `ec2`, then `vpc`. |

Applying happens only from a manual run, in the environment's protection rules. Runs on the same environment and stack queue behind each other (`cancel-in-progress: false`, since a cancelled apply leaves a lock and a half-changed environment). GitHub keeps one waiting run per group: a third run replaces the one waiting, not the one running.

> **Plan files can contain secrets.** `tfplan` holds every input value in plain text, sensitive ones included, and anyone who can read a public repository can download its artifacts. Here the plan lives one day and the inputs hold no secrets. If yours do, encrypt the file before uploading it, or plan and apply in one job.

-----

## Workspaces and credentials

HashiCorp [recommends against](https://developer.hashicorp.com/terraform/cli/workspaces#when-not-to-use-multiple-workspaces) CLI workspaces when deployments need strong separation, such as different credentials and access controls per environment, because every workspace in a working directory shares one backend. Separate root modules (a directory per environment calling a shared module) are its suggested answer.

This repository keeps workspaces, which is the article's idea, and narrows the gap:

- each environment has its own role, which only a job in that GitHub environment can assume;
- that role can read and write only its own state prefix and assume only its own target role;
- each environment's resources live in its own account, and `allowed_account_ids` stops a run that points at the wrong one.

What stays shared: one bucket and one backend configuration, bucket listing (key names, not contents), and the code itself, so a change reaches every environment the moment it is applied there. Switch to separate root modules when environments need different backends or state accounts, different module versions promoted one environment at a time, different owners, or more environments and regions than a `choice` input holds comfortably.

-----

## What changed since 2023

| Then | Now | Why |
|------|-----|-----|
| IAM user access keys as repository secrets | GitHub OIDC, one role per environment (`bootstrap/`) | No long-lived credential to leak or rotate. |
| DynamoDB lock table | `use_lockfile = true` | Native S3 locking since Terraform 1.11; one resource fewer. |
| Default `env:/` workspace prefix | `workspace_key_prefix = "workspaces"` | Lets IAM scope each environment to its own state. |
| Modules from GitHub `master`, provider `>= 4.5` | Registry modules at exact versions, provider pinned, lock file committed | The same commit plans the same way next year. |
| `http_tcp_listeners`, `target_group_arns`, `computed_ingress_*` | `listeners`/`target_groups` maps, `traffic_source_attachments`, structured rules | Inputs renamed in alb v9, autoscaling v8, security-group v6. |
| Amazon Linux 2, metadata without a token | Amazon Linux 2023, IMDSv2 | AL2 support ended 2026-06-30; the autoscaling module enforces IMDSv2. |
| Actions by tag or `@master`, `owner/repo@main` | Actions by commit SHA, reusable workflow by local path | Tags can be moved (trivy-action's were, in March 2026); a local path runs the commit being tested. |
| Default token permissions | `permissions: {}` and per-job grants | Least privilege. |
| Plan and apply in one job, plan named `<env>.txt` | Plan job → `tfplan` artifact → apply job | The apply runs exactly what was shown. |
| No pull-request checks | fmt, validate, Trivy with SARIF | Problems surface before merge. |

Pinned versions: Terraform 1.17.1, AWS provider 6.71.0; modules vpc 6.7.3, s3-bucket 5.17.0, security-group 6.0.0, alb 10.5.1, autoscaling 9.3.2; actions checkout v7.0.1, configure-aws-credentials v6.3.0, setup-terraform v4.0.1, trivy-action v0.36.0 (Trivy v0.76.1), upload-artifact v7.0.2, download-artifact v8.0.2, codeql-action v4.39.1.

-----

## Inputs

### Common inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| target_account | Target AWS account ID. | `string` | `null` | yes (from the environment's `TARGET_ACCOUNT`) |
| target_region | Target AWS region name. | `string` | `null` | yes (from `TARGET_REGION`) |
| target_role | Target AWS IAM role name to be assumed. | `string` | `null` | yes (from `TARGET_ROLE`) |
| project | Project name. | `string` | `null` | yes |
| tags | A map of tags to assign to the resources. | `map(string)` | `{}` | no |

### VPC stack inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_cidr | The IPv4 CIDR block for the VPC. | `string` | `null` | yes |
| vpc_azs | A list of availability zones names or IDs in the target region. | `list(string)` | `[]` | no |
| vpc_public_subnets | A list of public subnets CIDR blocks inside the VPC. | `list(string)` | `[]` | no |
| vpc_private_subnets | A list of private subnets CIDR blocks inside the VPC. | `list(string)` | `[]` | no |
| vpc_database_subnets | A list of database subnets CIDR blocks inside the VPC. | `list(string)` | `[]` | no |
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
| vpc_flow_log_max_aggregation_interval | The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds. | `number` | `600` | no |

### EC2 stack inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| alb_load_balancer_type | The type of load balancer to create. Possible values are application or network. **Please note: Only `"application"` loadbalancer type can be used within this project!** | `string` | `"application"` | no |
| alb_internal | Boolean determining if the load balancer is internal or externally facing. | `bool` | `false` | no |
| alb_enable_deletion_protection | Whether deletion of the load balancer is disabled. The ALB module defaults to `true` since v9; `false` keeps destroy-all working. | `bool` | `false` | no |
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
| autoscaling_update_default_version | Whether to update Default Version each update. **Please note: only `true` is supported within this project.** | `bool` | `true` | no |
| autoscaling_instance_type | The type of the instance. | `string` | `null` | no |
| autoscaling_ebs_optimized | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `null` | no |
| autoscaling_enable_monitoring | Enables/disables detailed monitoring. | `bool` | `true` | no |
| autoscaling_create_iam_instance_profile | Determines whether an IAM instance profile is created or to use an existing IAM instance profile. **Please note: only `true` is supported within this project.** | `bool` | `true` | no |
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
