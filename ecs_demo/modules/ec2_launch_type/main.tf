############################
# VPC
############################

# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "ecs-vpc"
#   }
# }


# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "ecs-igw"
#   }
# }

############################
# Public Subnet 1
############################

# resource "aws_subnet" "public_1" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "${var.region}a"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "ecs-public-subnet-1"
#   }
# }

############################
# Public Subnet 2
############################

# resource "aws_subnet" "public_2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.2.0/24"
#   availability_zone       = "${var.region}b"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "ecs-public-subnet-2"
#   }
# }

# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = {
#     Name = "ecs-public-rt"
#   }
# }
# resource "aws_route_table_association" "public_assoc_1" {
#   subnet_id      = aws_subnet.public_1.id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table_association" "public_assoc_2" {
#   subnet_id      = aws_subnet.public_2.id
#   route_table_id = aws_route_table.public.id
# }
# ############################
# # Security Group
# ############################

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-instance-sg"
  description = "ECS EC2 security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ############################
# # ECS Cluster
# ############################

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

# ############################
# # IAM Role for ECS EC2
# ############################

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role_policy_attachment" "ecs_ec2_role1" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

############################
# ECS Optimized AMI
############################

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

############################
# Launch Template
############################

resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-template-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Enforces IMDSv2
  }

  user_data = base64encode(<<EOF
          #!/bin/bash
          echo ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config
          EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecs-instance"
    }
  }
}

############################
# Auto Scaling Group
############################

resource "aws_autoscaling_group" "ecs_asg" {
  name             = "asg-2"
  desired_capacity = var.desired_capacity
   lifecycle {
    ignore_changes = [desired_capacity]
  }
  max_size         = 2
  min_size         = 1

  vpc_zone_identifier = [
    for key, subnet in var.private_subnets :
      subnet.id
  ]

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecs-asg-instance"
    propagate_at_launch = true
  }
}

############################
# Capacity Provider
############################

resource "aws_ecs_capacity_provider" "cp" {
  name = "app-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_cp" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [
    aws_ecs_capacity_provider.cp.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cp.name
    weight            = 1
  }
}

############################
# ECS Task Definition
############################

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "ec2_task_defination"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  cpu    = "512"
  memory = "512"

  container_definitions = jsonencode([
    {
      name      = "app-1"
      image     = "186581960368.dkr.ecr.ap-south-1.amazonaws.com/my-app-repo:latest"
      essential = true

      cpu    = 512
      memory = 512
      memoryReservation = 256

      portMappings = [
        {
          containerPort = 8081
          hostPort      = 8081
          protocol      = "tcp"
        }
      ]

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
  ])
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/my-ec2-app"
  retention_in_days = 7

  tags = {
    Name = "ecs-log-group"
  }
}


############################
# ECS Service
############################

resource "aws_ecs_service" "service_1" {
  name            = "service-ec2"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.task_definition.id
  desired_count   = 2


  # launch_type = "EC2"
   force_new_deployment = true
capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cp.name
    weight            = 1
    base              = 1  # guarantees at least 1 task on this provider
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "app-1"
    container_port   = 8081
  }

  placement_constraints {
    type = "distinctInstance"
  }
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [
    aws_autoscaling_group.ecs_asg
  ]
}


############################
# ALB Security Group
############################

resource "aws_security_group" "alb_sg" {
  name        = "ecs-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# Application Load Balancer
############################

resource "aws_lb" "ecs_alb" {
  name               = "ecs-application-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
     for az, subnets in var.public_subnets_az :
    subnets[0].id
  ]

  enable_deletion_protection = false
}

############################
# Target Group
############################

resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-target-group"
  port        = 8081
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

############################
# Listener
############################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}



resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 6
  min_capacity       = 1
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.service_1.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "memory_policy" {
  name               = "memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0 # memory %

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }

}
