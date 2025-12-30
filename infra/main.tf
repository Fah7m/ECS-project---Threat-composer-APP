# VPC module

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ECS module

module "ecs" {
  source = "./modules/ecs"

  vpc_id                                      = module.vpc.vpc_id
  container_port                              = var.container_port
  ecs_task_desired_count                      = var.ecs_task_desired_count
  ecs_task_deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  ecs_task_deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent
  service_name                                = var.service_name
  alb_sg_id                                   = module.alb.alb_sg_id
  target_group_arn                            = module.alb.target_group_arn
  private_subnet_ids                          = module.vpc.private_subnet_ids
  container_image                             = var.container_image
  aws_logs_region                             = var.aws_logs_region
  execution_role_arn                          = module.iam.ecs_task_execution_role_arn
  task_role_arn                               = module.iam.ecs_task_role_arn
}

# ALB module

module "alb" {
  source = "./modules/alb"

  vpc_id              = module.vpc.vpc_id
  target_group_port   = var.target_group_port
  acm_certificate_arn = module.acm.certificate_arn
  public_subnet_ids   = module.vpc.public_subnet_ids
}

# IAM module

module "iam" {
  source = "./modules/iam"
}


# Route53 module

module "route53" {
  source = "./modules/route53"

  domain_name     = var.domain_name
  sub_domain_name = var.sub_domain_name
  alb_dns_name    = module.alb.alb_dns_name
  alb_zone_id     = module.alb.alb_zone_id
}

# ACM module

module "acm" {
  source = "./modules/acm"

  route53_zone_id = module.route53.zone_id
  sub_domain_name = var.sub_domain_name
}