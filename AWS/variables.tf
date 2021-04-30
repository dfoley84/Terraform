
variable "aws_profile"{}
variable "aws_region_Dublin"{}
variable "aws_region_London"{}
variable "aws_region_Paris"{}
variable "Jenkin_AMI"{} 
variable "JenkinMaster_SG_group"{}
variable "JenkinSlave_SG_group"{}
variable "instance_class" {}
variable "key_name"{}
variable "domain_name"{}
variable "public_key_path" {}

data "aws_availability_zones" "available" {}

variable "cidrs" {
    type = "map"
}

variable "SP_cidrs" {
    type = "map"
}



