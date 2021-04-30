variable "apache_bucket_name" {}
variable "aws_region" {}
variable "key_name" {}
variable "public_key_path" {}
variable "instance_class" {}

variable "cidrs" {
  type = "map"
}

variable "SP_cidrs" {
  type = "map"
}

variable "work_ipaddress" {}
