output "zone_id" {
  description = "The ID of the Route 53 hosted zone."
  value       = data.aws_route53_zone.zone.zone_id
}
