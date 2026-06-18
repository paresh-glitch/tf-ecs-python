variable "vpc_cidr" {}
variable "vpc_name" {}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "azs" {
  type = list(string)
}
variable "alb_name" {}
variable "cluster_name" {}
variable "repo_names" {
  type = list(string)
}
variable "db_user" {}
variable "db_password" {}
variable "db_name" {}
variable "env" {}
