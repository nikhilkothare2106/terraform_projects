# variable "vpc_config" {
#   description = "Vpc information"
#   type = object({
#     cidr_block = string
#     name       = string
#   })
# }

variable "region" {
  default = "ap-south-1"
  description = "Region"
  type        = string

}
variable "subnet_config" {
  description = "CIDR and AZ of Subnets"
  type = map(object({
    cidr_block = string
    az         = string
    public     = bool

  }))
}
variable "ami_id" {
  description = "AMI id"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

