# OUTPUTS

output "environment_role_arns" {
  description = "Per GitHub environment: the value of its AWS_ROLE_ARN variable."
  value       = { for env, role in aws_iam_role.environment : env => role.arn }
}

output "state_bucket" {
  description = "The state bucket name."
  value       = aws_s3_bucket.state.id
}

output "oidc_provider_arn" {
  description = "The GitHub OIDC provider ARN."
  value       = local.oidc_provider_arn
}
