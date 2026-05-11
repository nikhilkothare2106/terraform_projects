resource "aws_ecs_service" "app_service1" {
  name            = "my-app-service1"
  cluster         = var.cluster_id
  task_definition = var.task_defination_id1
  desired_count   = 2

  launch_type = "FARGATE"

  network_configuration {
    subnets = [
      for key, subnet in var.private_subnets :
      subnet.id

    ]

    security_groups = [var.ecs_sg]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.app_tg_arn
    container_name   = "my-app"
    container_port   = 8081
  }

#  # Second container
#   load_balancer {
#     target_group_arn = var.app_tg_2_arn
#     container_name   = "my-app-1"
#     container_port   = 8082
#   }
  depends_on = [ var.instance1]
}



# resource "aws_ecs_service" "app_service2" {
#   name            = "my-app-service2"
#   cluster         = var.cluster_id
#   task_definition = var.task_defination_id2
#   desired_count   = 2

#   launch_type = "FARGATE"

#   network_configuration {
#     subnets = [
#       for key, subnet in var.private_subnets :
#       subnet.id
#     ]

#     security_groups = [var.ecs_sg]

#     assign_public_ip = false
#   }

  # load_balancer {
  #   target_group_arn = var.app_tg_arn
  #   container_name   = "my-app"
  #   container_port   = 8081
  # }

#   load_balancer {
#     target_group_arn = var.app_tg_2_arn
#     container_name   = "my-app-1"
#     container_port   = 8082
#   }
#   depends_on = [ var.instance1]
# }
