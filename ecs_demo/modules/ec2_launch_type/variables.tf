variable "region" {
  description = "Region"
  type        = string
}

variable "cluster_name" {
  default = "ecs-ec2-cluster"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "desired_capacity" {
  default = 1
}
variable "public_subnets_az" {
}
variable "vpc_id" {
}
variable "private_subnets" {
}