resource "aws_lb" "app_alb" {
  name               = "my-app-alb"
  load_balancer_type = "application"

  subnets = [
    for az, subnets in var.public_subnets_az :
    subnets[0].id
  ]

  security_groups = [var.alb_sg]
}

resource "aws_lb_target_group" "app_tg" {
  name        = "my-app-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/health"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


resource "aws_lb_target_group" "app_tg_2" {
  name        = "my-app-tg-2"
  port        = 8082
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/health"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_lb_listener_rule" "app1_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  condition {
    path_pattern {
      values = ["/hi"]
    }
  }
}

resource "aws_lb_listener_rule" "app2_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg_2.arn
  }

  condition {
    path_pattern {
      values = ["/hello"]
    }
  }
}
