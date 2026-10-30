# TARGET ROLE

resource "aws_iam_role" "target" {
  name                 = var.role_name
  description          = "Terraform in this account, reached by role chaining from the management account."
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = 3600
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.target.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "stack_iam" {
  name   = "stack-iam"
  role   = aws_iam_role.target.id
  policy = data.aws_iam_policy_document.stack_iam.json
}
