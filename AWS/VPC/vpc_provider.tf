provider "aws" {
    region = "${var.aws_region_Dublin}"
    profile ="${var.aws_profile}"
}

# VPC 
resource "aws_vpc" "Dublin_vpc" {
  cidr_block = "${var.aws_cidr}"
  tags{
      Name = "Dublin_VPC"
  }
}

# Gateway

resource "aws_internet_gateway" "Dublin_internet_gateway" {
    vpc_id = "${aws_vpc.Dublin_vpc.id}"

    tags {
        Name = "Dublin_igw"
    }
}

# Route Table Public

resource "aws_route_table" "Dublin_public_rt" {
  vpc_id = "${aws_vpc.Dublin_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
	  gateway_id = "${aws_internet_gateway.Dublin_internet_gateway.id}"
	}
  tags {
	Name = "Dublin Public Route"
  }
}

# Route Table Private

resource "aws_default_route_table" "Dublin_private_rt" {
  default_route_table_id = "${aws_vpc.Dublin_vpc.default_route_table_id}"
  tags {
    Name = "Dublin Private Route"
  }
}


# Public Subnet

resource "aws_subnet" "Dublin_public_subnet" {
  vpc_id = "${aws_vpc.Dublin_vpc.id}"
  cidr_block = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "Dublin public Subnet"
  }
}

# Private Subnet

resource "aws_subnet" "Dublin_private_subnet" {
  vpc_id = "${aws_vpc.Dublin_vpc.id}"
  cidr_block = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags {
    Name = "Dublin private subnet"
  }
}

# Subnet Association

resource "aws_route_table_association" "Dublin_public_assoc" {
  subnet_id = "${aws_subnet.Dublin_public_subnet.id}"
  route_table_id = "${aws_route_table.Dublin_public_rt.id}"
}

resource "aws_route_table_association" "Dublin_private_assoc" {
    subnet_id = "${aws_subnet.Dublin_private_subnet.id}"
    route_table_id = "${aws_default_route_table.Dublin_private_rt.id}"
}



# Public Security Groups 

resource "aws_security_group" "Dublin_Development_SG" {
  name = "Dublin_Development_SG"
  description = "Access to Development Instance"
  vpc_id =  "${aws_vpc.Dublin_vpc.id}"

  #SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.SP_cidrs["work_ipaddress"]}","${var.SP_cidrs["home_ipaddress"]}"]

  }

  #HTTP
  ingress {
    from_port = 80 
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.SP_cidrs["work_ipaddress"]}","${var.SP_cidrs["home_ipaddress"]}"]
  }

egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks =["0.0.0.0/0"]
}
}

resource "aws_security_group" "Dublin_public_SG" {
  name = "Dublin_public_SG"
  description = "Used for the ELB for public Access"
  vpc_id =  "${aws_vpc.Dublin_vpc.id}"

  #HTTP 
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =["0.0.0.0/0"]
  }
egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks =["0.0.0.0/0"]
}
}

# Private Security Group
resource "aws_security_group" "Dublin_private_sg" {
  name = "Dublin_private_sg"
  description = "Used for Private EC2"
  vpc_id = "${aws_vpc.Dublin_vpc.id}"

# Access From VPC
ingress {
  from_port = 0
  to_port = 0
  protocol = "-1"
}

egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
   cidr_blocks =["0.0.0.0/0"]
}
}

