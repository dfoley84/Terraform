#Using AWS Terraform Module to Create VPC Network and Subnet within AWS 

# Providers
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "us-east1"
}

# Resrouces 
# Using AWS Terraform Moduel
# https://github.com/terraform-aws-modules/terraform-aws-vpc

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "VPC"
  cidr = "172.26.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["172.26.10.0/24", "172.26.20.0/24", "172.26.30.0/24"]
  public_subnets  = ["172.26.40.0/24", "172.26.50.0/24", "172.26.60.0/24"]
  
  enable_nat_gateway = true
  create_database_subnet_group = false

  tags = {
    Terraform = "true"
    Environment = "Production"
  }
}
