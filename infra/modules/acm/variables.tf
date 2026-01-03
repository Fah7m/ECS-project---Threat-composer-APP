variable "sub_domain_name" {
  description = "The subdomain name for the ACM certificate."
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone."
  type        = string
}

