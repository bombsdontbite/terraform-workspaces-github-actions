# OUTPUTS

output "vpc_id" {
  value = module.vpc.vpc_id
}
  
output "azs" {
  value = module.vpc.azs
}
  
output "public_subnets" {
  value = module.vpc.public_subnets
}
  
output "http_security_group_id" {
  value = module.http_security_group.security_group_id
}
