output "target_group_arn" {
  description = "The ARN of the ALB target group."
  value       = aws_alb_target_group.service_target_group.arn
}

output "alb_sg_id" {
  description = "The ID of the ALB security group."
  value       = aws_security_group.alb_sg.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = aws_alb.ecs_alb.dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB."
  value       = aws_alb.ecs_alb.arn
}

output "alb_sg_cidr_block" {
  description = "The CIDR block associated with the ALB security group."
  value       = aws_security_group.alb_sg.id
}

output "alb_zone_id" {
  description = "The Zone ID of the ALB."
  value       = aws_alb.ecs_alb.zone_id
}

