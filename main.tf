provider "aws" {
  region = "ap-south-1"
}

data "aws_iam_role" "ecs_execution" {
  name = "ecsTaskExecutionRole"
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "ecr" {
  source     = "./modules/ecr"
  env        = var.env
  repo_names = var.repo_names
}

module "alb" {
  source            = "./modules/alb"
  alb_name          = var.alb_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn
  repo_urls          = module.ecr.repo_urls
  execution_role_arn = data.aws_iam_role.ecs_execution.arn
  db_user     = var.db_user
  db_password = var.db_password
  db_name     = var.db_name
  flask_repo_name = "${var.env}-flask-app"
  nginx_repo_name = "${var.env}-nginx"
  alb_listener_arn = module.alb.alb_listener_arn
}
