variable "aws_region"{}
variable "aws_access_key" {}
variable "aws_secret_key"{}

data "aws_availability_zones" "available" {}

variable "vpc_cidr" {}

variable "cidrs" {
  type = "map"
}

variable "localip" {}