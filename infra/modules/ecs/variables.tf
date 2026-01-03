variable "container_port" {
  description = "The port on which the container listens."
  type        = number
}

variable "ecs_task_desired_count" {
  description = "The desired number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "ecs_task_deployment_minimum_healthy_percent" {
  description = "The minimum healthy percent for ECS task deployment."
  type        = number
  default     = 50
}

variable "ecs_task_deployment_maximum_percent" {
  description = "The maximum percent for ECS task deployment."
  type        = number
  default     = 200
}

variable "service_name" {
  description = "The name of the ECS service."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where ECS resources will be deployed."
  type        = string
}


variable "alb_sg_id" {
  description = "The ID of the ALB security group."
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group for the ECS service."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks."
  type        = list(string)
}

variable "container_image" {
  description = "The Docker image for the ECS container."
  type        = string
}

variable "aws_logs_region" {
  description = "The AWS region for CloudWatch logs."
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the IAM role that allows ECS tasks to make AWS API calls."
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the IAM role that the ECS task can assume."
  type        = string
}
