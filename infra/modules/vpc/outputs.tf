output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.ecs_vpc.id
}

output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value       = aws_subnet.private_subnet[*].id
}

output "availability_zones" {
  description = "List of Availability Zones used"
  value       = var.availability_zones
}