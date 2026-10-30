# DATA

data "aws_partition" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

# Only a job running in GitHub environment <env> of this repository gets <env>'s role.
data "aws_iam_policy_document" "github_trust" {
  for_each = var.environments
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["${var.github_subject_prefix}:environment:${each.key}"]
    }
  }
}

data "aws_iam_policy_document" "environment" {
  for_each = var.environments

  # Listing shows key names of every environment, never their contents. The S3 backend lists
  # to find workspaces, and init reads the default workspace's (absent) state, which S3
  # answers with 404 only to a caller allowed to list.
  statement {
    sid       = "ListStateBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]
  }
  statement {
    sid       = "ReadWriteOwnWorkspaceState"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.state.arn}/${var.workspace_key_prefix}/${each.key}/*"]
  }
  statement {
    sid       = "ReleaseOwnLocks"
    actions   = ["s3:DeleteObject"]
    resources = ["${aws_s3_bucket.state.arn}/${var.workspace_key_prefix}/${each.key}/*.tflock"]
  }
  statement {
    sid       = "ReadDefaultWorkspaceKeys"
    actions   = ["s3:GetObject"]
    resources = [for stack in var.stacks : "${aws_s3_bucket.state.arn}/${stack}/terraform.tfstate"]
  }
  statement {
    sid       = "AssumeOwnTargetRole"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:${data.aws_partition.current.partition}:iam::${each.value.target_account_id}:role/${var.target_role_name}"]
  }
}

data "aws_iam_policy_document" "state_bucket" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
