provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

# ---------- S3 Bucket -----------------
resource "random_id" "bucket_id" {
  byte_length = 3
}

resource "aws_s3_bucket" "S3 Bucket" {
  bucket        = "${var.apache_bucket_name}-${random_id.bucket_id.dec}"
  acl           = "private"
  force_destroy = true

  tags {
  }
}

# ---------- AWS VPC ------------------

data "aws_availability_zone" "vpc_zone" {}

# Creating VPC for Apache Deployment 
resource "aws_vpc" "Apache_vpc" {
  cidr_block           = "213.127.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "Apache Deployment"
  }
}

# Gateway for public subnet
resource "aws_internet_gateway" "Apache_Internet_gateway" {
  vpc_id = "${aws_vpc.Apache_vpc.id}"

  tags {
    Name = "Apache_igw"
  }
}

# Route Table Public
resource "aws_route_table" "Public_Route_Table" {
  vpc_id = "${aws_vpc.Apache_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Apache_Internet_gateway.id}"
  }

  tags {
    Name = "Public Route"
  }
}

# Route Table Private
resource "aws_default_route_table" "Private_Route_Table" {
  default_route_table_id = "${aws_vpc.Apache_vpc.default_route_table_id}"

  tags {
    Name = "Private Route"
  }
}

# NAT for Private Subnet
##resource "aws_nat_gateway" "Private_NAT" {
# depends_on = ["aws_internet_gateway.gw"]

# Apache Public Subnet 1A
resource "aws_subnet" "Public_Subnet_1A" {
  vpc_id                  = "${aws_vpc.Apache_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "Public_Subnet_1A"
  }
}

# Apache Public Subnet 1C

resource "aws_subnet" "Public_Subnet_1C" {
  vpc_id                  = "${aws_vpc.Apache_vpc.id}"
  cidr_block              = "${var.cidrs["public2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "Public_Subnet_1C"
  }
}

# Apache Private Subnet 1A 

resource "aws_subnet" "Private_Subnet_1A" {
  vpc_id                  = "${aws_vpc.Apache_vpc.id}"
  cidr_block              = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "Private_Subnet_1A"
  }
}

# Apache Private Subnet 1C
resource "aws_subnet" "Private_Subnet_1C" {
  vpc_id                  = "${aws_vpc.Apache_vpc.id}"
  cidr_block              = "${var.cidrs["private2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "Private_Subnet_1C"
  }
}

# Adding Subnets to Route Table
resource "aws_route_table_association" "bastion_route" {
  subnet_id      = ["${aws_subnet.Public_Subnet_1A.id}", "${aws_subnet.Public_Subnet_1C.id}"]
  route_table_id = "${aws_route_table.Public_Route_Table.id}"
}

resource "aws_route_table_association" "web" {
  subnet_id      = ["${aws_subnet.Private_Subnet_1A.id}", "${aws_subnet.Private_Subnet_1C.id}"]
  route_table_id = "${aws_route_table.Private_Route_Table.id}"
}

# Public Security Groups 

resource "aws_security_group" "Bastion_SG" {
  name        = "Bastion_SG"
  description = "Access to Bastion Host"
  vpc_id      = "${aws_vpc.Apache_vpc.id}"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.SP_cidrs["work_ipaddress"]}", "${var.SP_cidrs["home_ipaddress"]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private  Security Groups 
resource "aws_security_group" "Private_Web" {
  name        = "Dublin_public_SG"
  description = "Used for the ELB for public Access"
  vpc_id      = "${aws_vpc.Apache_vpc.id}"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.SP_cidrs["public1"]}", "${var.SP_cidrs["public2"]}"]
  }

  #HTTP 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- EC2 Instance ------------------
data "template_file" "salt_minion" {
  count    = 2
  template = "${file("${path.module}/salt.tpl")}"
}

data "aws_ami" "server_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion_ec2" {
  count                       = 2
  instance_type               = "${var.instance_class}"
  ami                         = "${data.aws_ami.server_ami.id}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.aws_subnet}"
  associate_public_ip_address = true
  security_groups             = ["${var.security_group}", "${aws_security_group.httpd-sg.id}"]
  key_name                    = "${var.key_name}"

  tags {
    name = "Bastion Host"
  }

  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key)}"
  }
}


resource "aws_instance" "Jenkins" {
  count                       = 2
  instance_type               = "${var.instance_class}"
  ami                         = "${data.aws_ami.server_ami.id}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.aws_subnet_Jenkins}"
  associate_public_ip_address = false
  security_groups             = "${var.security_group}"
  key_name                    = "${var.key_name}"

  tags {
    name = "Jenkins Server"
  }

  connection {
    user  = "ec2-user"
    private_key = "${file(var.private_key)}"
  }
}


#ELB
resource "aws_elb" "Jenkins_ELB" {
  name               = "Jenkins-elb"
  availability_zones = ["${data.aws_availability_zones.available.names[0]}","${data.aws_availability_zones.available.names[1]}"]

listener{
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"

}

 health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400


  

#Route 53 Jenkins
resource "aws_route53_record" "jenkinsNode" {
  zone_id = "${aws_route53_record.primary.zone_id}"
  name = "www.Jenkins.<HostDomain>.eu"
  type = "A"
  ttl = "300"
  records = ["${aws_eip.lb.Jenkins_ELB}"]
}

