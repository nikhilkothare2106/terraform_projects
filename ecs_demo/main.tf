module "network" {
  source        = "./modules/network"
  subnet_config = var.subnet_config
}
module "sg" {
  source = "./modules/sg"
  vpc_id = module.network.vpc_id
}
module "iam" {
  source = "./modules/iam"
}
module "ecr" {
  source = "./modules/ecr"
}
module "ec2" {
  source        = "./modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  ec2_sg        = module.sg.ec2_sg
  ecr_repo_url  = module.ecr.ecr_repo_url
  subnet_id     = module.network.public_subnets["public_subnet_1"].id
  ecr_repo_url1 = module.ecr.ecr_repo_url1
}

module "cluster" {
  source = "./modules/ecs/cluster"
}
module "task_definition" {
  source                  = "./modules/ecs/task_defination"
  ecr_repo_url            = module.ecr.ecr_repo_url
  ecs_task_execution_role = module.iam.ecs_task_execution_role
  ecr_repo_url1           = module.ecr.ecr_repo_url1
}
module "alb" {
  source            = "./modules/ecs/alb"
  alb_sg            = module.sg.alb_sg
  vpc_id            = module.network.vpc_id
  public_subnets_az = module.network.public_subnets_az
}
module "service" {
  source              = "./modules/ecs/service"
  instance1           = module.ec2.instance1
  ecs_sg              = module.sg.ecs_sg
  private_subnets     = module.network.private_subnets
  cluster_id          = module.cluster.cluster_id
  task_defination_id1 = module.task_definition.task_definition_id1
  app_tg_arn          = module.alb.app_tg_arn
  app_tg_2_arn        = module.alb.app_tg_2_arn
  # task_defination_id2 = module.task_definition.task_definition_id2
}
module "auto_scaling" {
  source       = "./modules/ecs/auto_scaling"
  cluster_name = module.cluster.cluster_name
  service_name = module.service.service_name
}
module "endpoint" {
  source                  = "./modules/endpoint"
  private_subnet_az       = module.network.private_subnets_az
  ecs_sg                  = module.sg.ecs_sg
  vpc_id                  = module.network.vpc_id
  private_route_table_ids = module.network.private_route_table_ids
}

module "ec2_launch_type"{
  source = "./modules/ec2_launch_type"
  region = var.region
    private_subnets     = module.network.private_subnets
  public_subnets_az = module.network.public_subnets_az
  vpc_id = module.network.vpc_id
}