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
