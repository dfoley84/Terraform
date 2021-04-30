provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

# ---------- Networking ------------------

resource "aws_vpc" "VPC" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "Apache Server"
  }
}

# Gateway for public subnet
resource "aws_internet_gateway" "Internet_gateway" {
  vpc_id = "${aws_vpc.VPC.id}"

  tags {
    Name = "igw"
  }
}

# Elastic IP for the NAT Gateway.
resource "aws_eip" "publicIP" {
  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "Private_NAT" {
  subnet_id     = "${aws_subnet.Public_Subnet_1A.id}"
  allocation_id = "${aws_eip.publicIP.id}"
  depends_on = "${aws_internet_gateway.Internet_gateway}"

  tags {
    Name = "Private NAT Web-Servers"
  }
}

# Route Table Public
resource "aws_route_table" "Public_Route_Table" {
  vpc_id = "${aws_vpc.VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Internet_gateway.id}"
  }

  tags {
    Name = "Public Route"
  }
}

# Private Default Table Private
resource "aws_default_route_table" "Private_Route_Table" {
  default_route_table_id = "${aws_vpc.VPC.default_route_table_id}"
  
  tags {
    Name = "Private Route"
  }
}

# Private Route Table for NAT
resource "aws_route" "NAT_route" {
    route_table_id = "${aws_default_route_table.Private_Route_Table}"
    destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.Private_NAT.id}"
}


# ---------- Subnets ------------------

#Public Subnet 1A
resource "aws_subnet" "Public_Subnet_1A" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "Public_Subnet_1A"
  }
}

#Public Subnet 1C
resource "aws_subnet" "Public_Subnet_1C" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.cidrs["public2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "Public_Subnet_1C"
  }
}

#Private Subnet 1A 
resource "aws_subnet" "Private_Subnet_1A" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "Private_Subnet_1A"
  }
}

#Private Subnet 1C
resource "aws_subnet" "Private_Subnet_1C" {
  vpc_id                  = "${aws_vpc.VPC.id}"
  cidr_block              = "${var.cidrs["private2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "Private_Subnet_1C"
  }
}

# Adding Subnets to Route Table
resource "aws_route_table_association" "Public_route1A" {
  subnet_id      = "${aws_subnet.Public_Subnet_1A.id}"
  route_table_id = "${aws_route_table.Public_Route_Table.id}"
}

resource "aws_route_table_association" "Private_route1A" {
  subnet_id      = "${aws_subnet.Private_Subnet_1A.id}"
  route_table_id = "${aws_default_route_table.Private_Route_Table.id}"
}

# Adding Subnets to Route Table
resource "aws_route_table_association" "Public_route1C" {
  subnet_id      = "${aws_subnet.Public_Subnet_1C.id}"
  route_table_id = "${aws_route_table.Public_Route_Table.id}"
}

resource "aws_route_table_association" "Private_route1C" {
  subnet_id      = "${aws_subnet.Private_Subnet_1C.id}"
  route_table_id = "${aws_default_route_table.Private_Route_Table.id}"
}

#--------------------- Security Groups --------------------------------------------------

# Bastion Security Group
resource "aws_security_group" "Bastion_Security_Group" {
  name        = "Bastion_SG"
  description = "Access to Bastion Host"
  vpc_id      = "${aws_vpc.VPC.id}"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.SP_cidrs["work"]}", "${var.SP_cidrs["home"]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Jenkins Security Groups
resource "aws_security_group" "Jenkins_Security_Group" {
  name        = "Jenkins Security Groupe"
  description = "Used for Jenkins EC2 Instnace"
  vpc_id      = "${aws_vpc.VPC.id}"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidrs["public1"]}", "${var.cidrs["public2"]}"]
  }

  # Apache TomCat 
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.SP_cidrs["work"]}", "${var.SP_cidrs["home"]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Private  Security Groups 
resource "aws_security_group" "Private_Web" {
  name        = "Private_SG"
  description = "Used for public Access"
  vpc_id      = "${aws_vpc.VPC.id}"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidrs["public1"]}", "${var.cidrs["public2"]}"]
  }

  #Salt Stack Firewall ports
  ingress {
    from_port   = 4505
    to_port     = 4506
    protocol    = "tcp"
    cidr_blocks = ["${var.cidrs["public1"]}", "${var.cidrs["public2"]}"]
  }

#Apache Web-Server https:
 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "https"
   cidr_blocks = ["0.0.0.0/0"]
  }

#Apache Web-Server http:
 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "http"
   cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#------------------- EC2 Instance ----------------------------------------------------------
#Bastion
resource "aws_instance" "Bastion" {
  ami             = "${var.Bastion_AMI}"
  instance_type   = "${var.Bastion_instance_class}"
  key_name        = "${var.key_name}"
  subnet_id       = "${aws_subnet.Public_Subnet_1A.id}"
  security_groups = ["${aws_security_group.Jenkins_Security_Group.id}"]
  tags {
    name = "Bastion Host"
  }

#Apache
resource "aws_instance" "Apache" {
  ami             = "${var.Jenkin_AMI}"
  instance_type   = "${var.jenkins_instance_class}"
  key_name        = "${var.key_name}"
  subnet_id       = "${aws_subnet.Private_Subnet_1C.id}"
  security_groups = ["${aws_security_group.Jenkins_Security_Group.id}"]

  tags {
    name = "Apache"
  }

  resource "aws_instance" "Apache1" {
  ami             = "${var.Jenkin_AMI}"
  instance_type   = "${var.jenkins_instance_class}"
  key_name        = "${var.key_name}"
  subnet_id       = "${aws_subnet.Private_Subnet_1A.id}"
  security_groups = ["${aws_security_group.Jenkins_Security_Group.id}"]

  tags {
    name = "Apache"
  }

#----------------------- AWS Load Balancer -------------------------------------------------

resource "aws_elb" "Apache" {
    name = "Apache ELB"
    subnet = ["${aws_subnet.Private_Subnet_1A.id}", "${aws_subnet.Private_Subnet_1C.id}"]
    security_groups = ["${aws_security_group.Private_Web.id}"]
    listener{
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
    }
     health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    target              = "TCP:80"
    interval            = 10    
  }

  cross-zone_load_balancing = true  
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags{
      Name = "Apach ELB"
  }
}

#TODO --> Moved to AWS LoadBlanacer from elb v1 to alb v2  


#---------------------- Route 53 --------------------------------------------
resource "aws_route53_record" "Jenkins" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "jenkins.<DOMAIN>.eu"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.lb.public_ip}"]
}
