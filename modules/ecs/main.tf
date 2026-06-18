resource "aws_security_group" "ecs" {
  name   = "${var.cluster_name}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.cluster_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "postgres"
      image     = "postgres:15"
      essential = true
      environment = [
        { name = "POSTGRES_USER",     value = var.db_user },
        { name = "POSTGRES_PASSWORD", value = var.db_password },
        { name = "POSTGRES_DB",       value = var.db_name }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "pg_isready -U ${var.db_user} -d ${var.db_name}"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    },
    {
      name      = "flask"
      image     = var.repo_urls[var.flask_repo_name]
      essential = true
      environment = [
        { name = "DB_HOST",     value = "127.0.0.1" },
        { name = "DB_USER",     value = var.db_user },
        { name = "DB_PASSWORD", value = var.db_password },
        { name = "DB_NAME",     value = var.db_name }
      ]
      dependsOn = [{ containerName = "postgres", condition = "HEALTHY" }]
    },
    {
      name      = "nginx"
      image     = var.repo_urls[var.nginx_repo_name]
      essential = true
      portMappings = [{ containerPort = 80, hostPort = 80 }]
      dependsOn = [{ containerName = "flask", condition = "START" }]
    }
  ])
} # <--- THIS WAS MISSING HERE! It closes the aws_ecs_task_definition resource.

resource "aws_ecs_service" "this" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  depends_on = [var.alb_listener_arn]
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }
}
