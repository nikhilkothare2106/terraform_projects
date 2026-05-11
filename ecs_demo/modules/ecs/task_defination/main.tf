
# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "my-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = var.ecs_task_execution_role

  container_definitions = jsonencode([
    {
      name  = "my-app"
      image = "${var.ecr_repo_url}:latest"

      essential = true

      portMappings = [{
        containerPort = 8081
        protocol      = "tcp"
      }]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8081/health || exit 1"]
        interval    = 30 # seconds
        timeout     = 5  # seconds
        retries     = 3
        startPeriod = 60 # give app time to start
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "ap-south-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
    # ,

    #  {
    #   name  = "my-app-1"
    #   image = "${var.ecr_repo_url1}:latest"

    #   essential = true

    #   portMappings = [{
    #     containerPort = 8082
    #     protocol      = "tcp"
    #   }]

    #   healthCheck = {
    #     command     = ["CMD-SHELL", "curl -f http://localhost:8082/health || exit 1"]
    #     interval    = 30 # seconds
    #     timeout     = 5  # seconds
    #     retries     = 3
    #     startPeriod = 60 # give app time to start
    #   }
    #   logConfiguration = {
    #     logDriver = "awslogs"
    #     options = {
    #       awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
    #       awslogs-region        = "ap-south-1"
    #       awslogs-stream-prefix = "ecs"
    #     }
    #   }
    # }
  ])
}



# # ECS Task Definition
# resource "aws_ecs_task_definition" "app1" {
#   family                   = "my-app1"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = "512"
#   memory                   = "1024"

#   execution_role_arn = var.ecs_task_execution_role

#   container_definitions = jsonencode([

#      {
#       name  = "my-app-1"
#       image = "${var.ecr_repo_url1}:latest"

#       essential = true

#       portMappings = [{
#         containerPort = 8082
#         protocol      = "tcp"
#       }]

#       healthCheck = {
#         command     = ["CMD-SHELL", "curl -f http://localhost:8082/health || exit 1"]
#         interval    = 30 # seconds
#         timeout     = 5  # seconds
#         retries     = 3
#         startPeriod = 60 # give app time to start
#       }
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group         = aws_cloudwatch_log_group.ecs_logs1.name
#           awslogs-region        = "ap-south-1"
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#     }
#   ])
# }

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/my-app"
  retention_in_days = 7

  tags = {
    Name = "ecs-log-group"
  }
}

# resource "aws_cloudwatch_log_group" "ecs_logs1" {
#   name              = "/ecs/my-app1"
#   retention_in_days = 7

#   tags = {
#     Name = "ecs-log-group"
#   }
# }
