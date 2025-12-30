variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}  

variable "target_group_port" {
  description = "The port on which the target group listens."
  type        = number
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for HTTPS listener."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

