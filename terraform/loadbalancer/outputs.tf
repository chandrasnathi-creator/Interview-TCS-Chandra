output "load_balancer_url" {
  description = "The URL of the application load balancer."
  value       = aws_lb.main.dns_name
}