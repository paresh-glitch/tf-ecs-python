variable "cluster_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "alb_sg_id" {}
variable "target_group_arn" {}
variable "repo_urls" {
  type = map(string)
}
variable "execution_role_arn" {}
variable "db_user" {}
variable "db_password" {}
variable "db_name" {}
variable "flask_repo_name" {}
variable "nginx_repo_name" {}
variable "alb_listener_arn" {}
