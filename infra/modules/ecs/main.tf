# ECS Cluster
resource "aws_ecs_cluster" "default" {
  name = "ECS-threat-app"

    setting {
        name  = "containerInsights"
        value = "enabled"
}
}

# ECS Security Group
resource "aws_security_group" "ecs_container_instance" {
  name        = "ecs-threat-app-container-instance-sg"
  description = "Security group for ECS threat app container instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name     = "ECS_Task_SecurityGroup"
  }

}

## Creates an ECS Service running on Fargate

resource "aws_ecs_service" "service" {
  name                               = "ECS-app"
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.default.arn
  desired_count                      = var.ecs_task_desired_count
  deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent
  launch_type                        = "FARGATE"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_container_instance.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "default" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = var.container_image
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.service_name}"
          "awslogs-region"        = var.aws_logs_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

