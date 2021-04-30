#----root/main.tf-----
provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}


# Deploy VPC Resources
module "networking" {
  source = "C:/Scripts/Terraform/Root Module/network"
  vpc_cidr    = "${var.vpc_cidr}"
  cidrs       = "${var.cidrs}"
  localip   = "${var.localip}"
  
}