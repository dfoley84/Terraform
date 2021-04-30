provider "aws" {
  region = "${var.region["Ireland"]}"
  alias = "Prd"
}

provider "aws" {
  region = "${var.region["London"]}"
  alias = "Dev"
}

# -------- Networking Stack -------------------------------------------

resource "aws_vpc" "vpc_prd" {
  provider = aws.Prd
  cidr_block = "172.27.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "Production"
    Environment = "Production"
  }
}

resource "aws_vpc" "vpc_dev" {
  provider = aws.Dev
  cidr_block = "172.26.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Development"
    Environment = "Development"
  }
}

resource "aws_internet_gateway" "igw_prd" {
  provider = aws.Prd
  vpc_id = "${aws_vpc.vpc_prd.id}"

  tags = {
    Name = "Production IGW"
    Environment = "Production"
  }
}

resource "aws_internet_gateway" "igw_dev" {
  provider = aws.Dev
  vpc_id = "${aws_vpc.vpc_dev.id}"

  tags = {
    Name = "Development IGW"
    Environment = "Development"
  }
}

# Peering VPC
resource "aws_vpc_peering_connection" "vpc_peering_prd" {
  peer_vpc_id = "${aws_vpc.vpc_dev.id}"
  vpc_id = "${aws_vpc.vpc_prd.id}"
  auto_accept = true
  provider = aws.Prd

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}


# Route Table Public
resource "aws_route_table" "rt_prd_public" {
  provider = aws.Prd
  vpc_id = "${aws_vpc.vpc_prd.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_prd.id}"
  }
  tags = {
    Name = "Production Public Route"
    Environment = "Production"
  }
}

resource "aws_route_table" "rt_dev_public" {
  vpc_id = "${aws_vpc.vpc_dev.id}"
  provider = aws.Dev
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_dev.id}"
  }
  tags = {
    Name = "Development Public Route"
    Environment = "Development"
  }
}


# Route Table Private
resource "aws_default_route_table" "rt_prd_private" {
  provider = aws.Prd
  default_route_table_id = "${aws_vpc.vpc_prd.default_route_table_id}"

  tags  = {
    Name = "Production Private Route"
    Environment = "Production"
  }
}

resource "aws_default_route_table" "rt_dev_private" {
  provider = aws.Dev
  default_route_table_id = "${aws_vpc.vpc_dev.default_route_table_id}"
 
  tags  = {
    Name = "Development Private Route"
    Environment = "Development"
  }
}

# Subnets

resource "aws_subnet" "subnet_prd_public" {
  vpc_id     = "${aws_vpc.vpc_prd.id}"
  cidr_block = "172.27.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1c"
  provider = aws.Prd

  tags = {
    Name = "Production_Public"
  }
}

resource "aws_subnet" "subnet_dev_public" {
  vpc_id     = "${aws_vpc.vpc_dev.id}"
  cidr_block = "172.26.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  provider = aws.Dev

  tags = {
    Name = "Development_Public"
  }
}

resource "aws_subnet" "subnet_prd_private" {
  vpc_id     = "${aws_vpc.vpc_prd.id}"
  cidr_block = "172.27.3.0/24"
  availability_zone = "us-east-1c"
  provider = aws.Prd

  tags = {
    Name = "Production_Private"
  }
}

resource "aws_subnet" "subnet_dev_private" {
  vpc_id     = "${aws_vpc.vpc_dev.id}"
  cidr_block = "172.26.3.0/24"
  availability_zone = "us-east-1c"
  provider = aws.Dev

  tags = {
    Name = "Development_Private"
  }
}

# Subnet Association
resource "aws_route_table_association" "prd_public_assoc" {
  provider = aws.Prd
  subnet_id = "${aws_subnet.subnet_prd_public.id}"
  route_table_id = "${aws_route_table.rt_prd_public.id}"
}

resource "aws_route_table_association" "Prd_private_assoc" {
  provider = aws.Prd
  subnet_id = "${aws_subnet.subnet_prd_private.id}"
  route_table_id = "${aws_default_route_table.rt_prd_private.id}"
}

resource "aws_route_table_association" "dev_public_assoc" {
  provider = aws.Prd
  subnet_id = "${aws_subnet.subnet_dev_public.id}"
  route_table_id = "${aws_route_table.rt_dev_public.id}"
}

resource "aws_route_table_association" "dev_private_assoc" {
  provider = aws.Prd
  subnet_id = "${aws_subnet.subnet_dev_private.id}"
  route_table_id = "${aws_default_route_table.rt_dev_private.id}"
}


#Peering
resource "aws_route_table_association" "dev_to_prd_private_assoc" {
  provider = aws.Prd
  subnet_id = "${aws_subnet.subnet_prd_private.id}"
  route_table_id = "${aws_default_route_table.rt_prd_private.id}"
}

resource "aws_route_table_association" "prd_to_dev_private_assoc" {
  provider = aws.Prd
  subnet_id = "${aws_subnet.subnet_dev_private.id}"
  route_table_id = "${aws_default_route_table.rt_dev_private.id}"
}


#Security Groups

resource "aws_security_group" "prd_bastion_sg" {
  provider = aws.Prd
  description = "Access to Bastion"
  vpc_id = "${aws_vpc.vpc_prd.id}"


  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dev_bastion_sg" {
  provider = aws.Dev
  description = "Access to Bastion"
  vpc_id = "${aws_vpc.vpc_dev.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dev_ssh_sg" {
  provider = aws.Prd
  description = "Access to Internal Account"
  vpc_id = "${aws_vpc.vpc_dev.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_subnet.subnet_dev_private.cidr_block}"]
  }
}


