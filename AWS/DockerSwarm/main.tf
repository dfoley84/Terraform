provider "aws" {
  alias = "Dub_Dev"
  region = var.dev_region
  profile = "Dev"
}

provider "aws" {
  alias = "Dub_Prd"
  region = var.prd_region
  profile = "Prd"
}

data "aws_availability_zones" "availability_dev" {
    provider = aws.Dub_Dev
}
data "aws_availability_zones" "availability_prd" {
    provider = aws.Dub_Prd
}

# Creating a VPC
resource "aws_vpc" "Dev_vpc" {
  cidr_block           = "172.127.0.0/16"
  provider =            aws.Dub_Dev
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "Deployment"
  }

  resource "aws_vpc" "Prd_vpc" {
  cidr_block           = "172.127.0.0/16"
  provider =            aws.Dub_Prd
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags {
    Name = "Production"
  }

# Gateway 
resource "aws_internet_gateway" "Dev_Internet_gateway" {
  vpc_id = "${aws_vpc.Dev_vpc.id}"
  provider = aws.Dub_Dev

  tags {
    Name = "Dev_igw"
  }
}

resource "aws_internet_gateway" "Prd_Internet_gateway" {
  vpc_id = "${aws_vpc.Prd_vpc.id}"
  provider = aws.Dub_Prd
  tags {
    Name = "Prd_igw"
  }
}