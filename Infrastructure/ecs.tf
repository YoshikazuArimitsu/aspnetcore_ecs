data "aws_caller_identity" "current" {}

resource "aws_security_group" "fargate" {
  name        = "${var.prefix}-fargate-sg"
  description = "sg for ${var.prefix}-fargate"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "from_alb_to_fargate" {
  security_group_id        = aws_security_group.fargate.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 0
  to_port                  = 65535
  source_security_group_id = aws_security_group.alb.id
  description              = "alb to fargate"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name               = "${var.prefix}-ecs-cluster"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 0
  }
}

resource "aws_ecs_service" "ecs" {
  name                               = "${var.prefix}-ecs"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.webapp.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets = local.private_subnets

    security_groups = [
      aws_security_group.fargate.id
    ]

    assign_public_ip = "false"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = "webapp"
    container_port   = "80"
  }

  health_check_grace_period_seconds = 0

  scheduling_strategy = "REPLICA"

  deployment_controller {
    # type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
  propagate_tags = "TASK_DEFINITION"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.prefix}-ecs-task-execution-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.prefix}-ecs-task-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

locals {
  web_container_definition = <<JSON
[
  {
    "name": "webapp",
    "image": "${aws_ecr_repository.webapp.repository_url}:latest",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "${var.prefix}",
        "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}"
      }
    },
    "portMappings": [
        {
            "containerPort": 80,
            "hostPort": 80
        }
    ],
    "command" : [
    ],
    "environment" : [
    ]
  }
]
JSON

}

resource "aws_ecs_task_definition" "webapp" {
  container_definitions    = local.web_container_definition
  family                   = "${var.prefix}_web"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]
}
