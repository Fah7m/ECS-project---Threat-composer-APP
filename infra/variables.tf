# Calling the VPC variables

variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "availability_zones" { type = list(string) }


# Calling the ECS variables

variable "container_port" { type = number }
variable "ecs_task_desired_count" { type = number }
variable "ecs_task_deployment_minimum_healthy_percent" { type = number }
variable "ecs_task_deployment_maximum_percent" { type = number }
variable "service_name" { type = string }




variable "container_image" { type = string }
variable "aws_logs_region" { type = string }

# Calling the ALB variables

variable "target_group_port" { type = number }


# Calling the Route53 variables

variable "domain_name" { type = string }
variable "sub_domain_name" { type = string }

# Calling the ACM variables


