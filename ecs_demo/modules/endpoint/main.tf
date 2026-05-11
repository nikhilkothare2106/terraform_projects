resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.ap-south-1.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for key, subnet in var.private_subnet_az: subnet[0].id]
  security_group_ids = [var.ecs_sg]
   private_dns_enabled = true 
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.ap-south-1.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for key, subnet in var.private_subnet_az: subnet[0].id]
  security_group_ids = [var.ecs_sg]
   private_dns_enabled = true 
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-south-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-south-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for key, subnet in var.private_subnet_az : subnet[0].id]
  security_group_ids  = [var.ecs_sg]
  private_dns_enabled = true
}