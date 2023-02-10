# OUTPUTS

output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb.lb_dns_name
}
