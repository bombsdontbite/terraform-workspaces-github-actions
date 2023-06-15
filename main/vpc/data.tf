# DATA

data "aws_availability_zones" "target" {
  provider = aws.target
  state    = "available"
}

data "aws_caller_identity" "target" {
  provider = aws.target
}

data "aws_region" "target" {
  provider = aws.target
}

data "aws_iam_policy_document" "flow_log_s3" {
  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${terraform.workspace}-${var.project}-flow-logs-${data.aws_caller_identity.target.account_id}-${data.aws_region.target.name}/AWSLogs/*"]
  }
  statement {
    sid = "AWSLogDeliveryAclCheck"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${terraform.workspace}-${var.project}-flow-logs-${data.aws_caller_identity.target.account_id}-${data.aws_region.target.name}"]
  }
}