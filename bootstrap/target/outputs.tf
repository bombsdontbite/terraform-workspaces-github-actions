# OUTPUTS

output "role_arn" {
  description = "The role Terraform assumes in this account."
  value       = aws_iam_role.target.arn
}
