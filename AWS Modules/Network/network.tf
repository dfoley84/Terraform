resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cdir.web
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "VPC"
  }
}

resource "aws_vpc" "management_vpc" {
  cidr_block = var.vpc_cdir.managment
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Management VPC"
  }
}

data "aws_availability_zones" "azs_zones" {
  state = "available"
}



resource "aws_subnet" "public" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 0 )
  cidr_block = var.subnet_cidr.public
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
    availability_zone = element(data.aws_availability_zones.azs_zones.names, 0 )
    cidr_block = var.subnet_cidr.private
    vpc_id = aws_vpc.vpc.id
    tags = {
      "Name" = "Private Subnet"
    }
  }

resource "aws_subnet" "management_public" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 0 )
  cidr_block = var.subnet_cidr.public
  vpc_id = aws_vpc.management_vpc.id
  tags = {
    "Name" = "Public Subnet"
  }
}

resource "aws_subnet" "management_private" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 0 )
  cidr_block = var.subnet_cidr.private
  vpc_id = aws_vpc.management_vpc.id
  tags = {
    "Name" = "Management Private Subnet"
  }
}

resource "aws_subnet" "management_private1" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 1 )
  cidr_block = var.subnet_cidr.private
  vpc_id = aws_vpc.management_vpc.id
  tags = {
    "Name" = "Management Private Subnet 1"
  }
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_internet_gateway" "management_vpc_igw" {
  vpc_id = aws_vpc.management_vpc.id
}

resource "aws_eip" "elastic_Nat" {
  vpc = true
  tags = {
    Name = "Nat Gateway Elastic IP"
  }
}

resource "aws_eip" "management_elastic_ip" {
  vpc = true
  tags = {
    Name = "Nat Gateway Elastic IP Management"
  }
}

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.elastic_Nat.id
  subnet_id = aws_subnet.public.id
  tags = {
    Name = "NAT GATEWAY"
  }
  depends_on = [aws_eip.elastic_Nat]
}

resource "aws_nat_gateway" "Managment_NAT" {
  allocation_id = aws_eip.management_elastic_ip.id
  subnet_id = aws_subnet.management_public.id
  tags = {
    Name = "Management NAT GATEWAY"
  }
  depends_on = [aws_eip.management_elastic_ip]
}