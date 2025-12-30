output "ecs_cluster_id" {
  description = "The ID of the ECS Cluster."
  value       = aws_ecs_cluster.default.id
}
output "ecs_service_name" {
  description = "The name of the ECS Service."
  value       = aws_ecs_service.service.name
}
output "ecs_service_arn" {
  description = "The ARN of the ECS Service."
  value       = aws_ecs_service.service.arn
}
