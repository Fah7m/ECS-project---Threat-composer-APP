variable "domain_name" {
  description = "The domain name for the Route 53 hosted zone."
  type        = string
}

variable "sub_domain_name" {
  description = "The subdomain name for the application (e.g., app.example.com)."
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB."
  type        = string
}
variable "alb_zone_id" {
  description = "The Zone ID of the ALB."
  type        = string
}