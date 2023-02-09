# DATA

data "aws_availability_zones" "target" {
  provider = aws.target
  state    = "available"
}
