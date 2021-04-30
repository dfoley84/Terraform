
provider "aws"
{
  region = "${var.region}"
  profile = "${var.aws_profile}"
}

# Creating VPC
resource "aws_vpc" "vpc"
{
  cidr_block = "172.27.0.0/16"
}

# Creating internet gateway
resource "aws_internet_gateway" "internet_gateway"
{
  vpc_id = "${aws_vpc.vpc.id}"
}

# Creating a Public Route
resource "aws_route_table" "public"
{
  vpc_id = "${aws_vpc.vpc.id}"
  route
  {
        cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.internet_gateway.id}"
	}
  tags {
	Name = "Public Route"
  }
}

#Creating a Private Route
resource "aws_default_route_table" "private"
{
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
  tags {
    Name = "Private Route"
  }
}

#Creating a Public Subnet
resource "aws_subnet" "public"
 {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "172.27.1.0/24"
  map_public_ip_on_launch = true
#  availability_zone = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "public Subnet"
  }
}

#Creating a Private Subnet
resource "aws_subnet" "private"
{
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "172.27.2.0/24"
  map_public_ip_on_launch = false
  #availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags {
    Name = "private subnet"
  }
}

#Setting up ACL / WAF Environment
#resource ""
