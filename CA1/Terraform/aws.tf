#Setting up AWS Region
provider "aws" {
  region = var.Production_Region
  profile = "production"
}


#--- IAM Roles & Policy  Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role_policy" "EC2_Policy" {
  name = var.ec2policy
  policy = "${file("ec2role.json")}"
  role = aws_iam_role.ec2_role.id
}

resource "aws_iam_role" "ec2_role" {
  assume_role_policy = "${file("ec2assume.json")}"
}

#Create an Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "test_profile_1"
  role = aws_iam_role.ec2_role.name
}

#Create a IAM Group
resource "aws_iam_group" "developers" {
  name = "Dev_Team"
  path = "/users/"
}

#Creating a Group Policy
resource "aws_iam_policy" "policy" {
  name        = var.Devpolicy
  policy      = "${file("DevPolicy.json")}"
}

#Attach Role Policy to Group
resource "aws_iam_group_policy_attachment" "policy-attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.policy.arn
}

#---------- VPC Network Stack Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
#Setting up the Bastion VPC
resource "aws_vpc" "bastion_vpc" {
  cidr_block           = var.vpc_cdir.bastion_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Bastion VPC"
  }
}

#Setting up the Web VPC
resource "aws_vpc" "web_vpc" {
  cidr_block           = var.vpc_cdir.web_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags =  {
    Name = "Web VPC"
  }
}


#---- Internet Gateway
resource "aws_internet_gateway" "bastion_igw" {
  vpc_id = aws_vpc.bastion_vpc.id
}

resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.web_vpc.id
}



#---- Getting AWS Availability Zones
data "aws_availability_zones" "azs_zones" {
  state = "available"
}



#Setting Up Availability Zone for Public Production
resource "aws_subnet" "bastion_Subnet" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 0 )
  cidr_block = var.subnet_cidr.bastion_Subnet
  vpc_id = aws_vpc.bastion_vpc.id
  tags = {
    "Name" = "Bastion Subnet"
  }
}

resource "aws_subnet" "bastion_Subnet1" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 1 )
  cidr_block = var.subnet_cidr.bastion_Subnet2
  vpc_id = aws_vpc.bastion_vpc.id
  tags = {
    "Name" = "Bastion Subnet"
  }
}

#-- Subnet for Public Web
resource "aws_subnet" "web_public" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 0 )
  cidr_block = var.subnet_cidr.public_subnet1
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    "Name" = "Public Subnet"
  }
}

resource "aws_subnet" "web_public2" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 1 )
  cidr_block = var.subnet_cidr.public_subnet2
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    "Name" = "Public Subnet"
  }
}



#-- Subnet for Private Web
resource "aws_subnet" "prd_private1" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 0 )
  map_public_ip_on_launch = false
  cidr_block = var.subnet_cidr.private_subnet1
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    "Name" = "Private  Subnet"
  }
}

resource "aws_subnet" "prd_private2" {
  availability_zone = element(data.aws_availability_zones.azs_zones.names, 1 )
  map_public_ip_on_launch = false
  cidr_block = var.subnet_cidr.private_subnet2
  vpc_id = aws_vpc.web_vpc.id
  tags = {
    "Name" = "Private  Subnet 1"
  }
}


#----- NAT Gateway Elastic IP Address
resource "aws_eip" "elastic_Nat" {
  vpc = true
  tags = {
    Name = "Nat Gateway Elastic IP"
  }
}

#Setting up the NAT Gateway Adding to Public Subnet on WEB VPC
resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.elastic_Nat.id
  subnet_id = aws_subnet.web_public.id
  tags = {
    Name = "NAT GATEWAY"
  }
  depends_on = [aws_eip.elastic_Nat]
}



#--- VPC Peering Between Bastion and WebServers Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection
resource "aws_vpc_peering_connection" "Bastion-Web" {
  peer_vpc_id = aws_vpc.web_vpc.id
  vpc_id = aws_vpc.bastion_vpc.id
  peer_region = var.Production_Region
}


#Accpet the Request For the Peering Connection
resource "aws_vpc_peering_connection_accepter" "peering_conncetion" {
  auto_accept = true
  vpc_peering_connection_id = aws_vpc_peering_connection.Bastion-Web.id
}


#Create a Public Route Table For the Bastion Host
resource "aws_route_table" "Bastion_Public_Route_Table" {
  vpc_id = aws_vpc.bastion_vpc.id

  route { #Create a Public Route
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bastion_igw.id
  }
  route { #Create a Route to the Peering Connection
    cidr_block = var.subnet_cidr.public_subnet1
    vpc_peering_connection_id = aws_vpc_peering_connection.Bastion-Web.id
  }
  route { #Create a Route to the Peering Connection
    cidr_block = var.subnet_cidr.private_subnet2
    vpc_peering_connection_id = aws_vpc_peering_connection.Bastion-Web.id
  }
  route { #Create a Route to the Peering Connection
    cidr_block = var.subnet_cidr.private_subnet1
    vpc_peering_connection_id = aws_vpc_peering_connection.Bastion-Web.id
  }
  route {
    #Create a Route to the Peering Connection
    cidr_block = var.subnet_cidr.private_subnet2
    vpc_peering_connection_id = aws_vpc_peering_connection.Bastion-Web.id
  }
  tags = {
    Name = "Bastion Public Route"
  }
}

#Public Route for WebServers
resource "aws_route_table" "Web_Public_Route_Table" {

  vpc_id = aws_vpc.web_vpc.id

  route { #Create a Public Route
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
  route { #Create a Route to the Peering Connection
    cidr_block = var.subnet_cidr.bastion_Subnet
    vpc_peering_connection_id = aws_vpc_peering_connection.Bastion-Web.id
  }

  tags = {
    Name = "Public Route"
  }
}


#--- Private Default Table Private
resource "aws_default_route_table" "Private_Route_Table" {
  default_route_table_id = aws_vpc.web_vpc.default_route_table_id
  route { #Add NAT Gateway
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT.id
  }
  route {
    cidr_block = var.subnet_cidr.bastion_Subnet
    vpc_peering_connection_id = aws_vpc_peering_connection.Bastion-Web.id
  }
  tags = {
    Name = "Private Route"
  }
}


#--- Adding Subnets to Route Table
resource "aws_route_table_association" "Public_route" {
  subnet_id      = aws_subnet.web_public.id
  route_table_id = aws_route_table.Web_Public_Route_Table.id
}

resource "aws_route_table_association" "Public_route1" {
  subnet_id      = aws_subnet.web_public2.id
  route_table_id = aws_route_table.Web_Public_Route_Table.id
}

resource "aws_route_table_association" "basiton_route1" {
  subnet_id      = aws_subnet.bastion_Subnet.id
  route_table_id = aws_route_table.Bastion_Public_Route_Table.id
}

resource "aws_route_table_association" "private_route" {
  subnet_id      = aws_subnet.prd_private2.id
  route_table_id =aws_default_route_table.Private_Route_Table.id
}

resource "aws_route_table_association" "private_route1" {
  subnet_id      = aws_subnet.prd_private2.id
  route_table_id = aws_default_route_table.Private_Route_Table.id
}

#--------------------- Security Groups
# Bastion Security Group
resource "aws_security_group" "Bastion_Security_Group" {
  name        = "Bastion_SG"
  description = "Access to Bastion Host"
  vpc_id      =  aws_vpc.bastion_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Bastion"
  }
}

# Web Site Security Groups
resource "aws_security_group" "Private_Web" {
  name        = "Web_Private_SG"
  description = "Used for public Access"
  vpc_id      = aws_vpc.web_vpc.id

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.Bastion_Security_Group.id]
  }

  #Apache Web-Server https:
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Apache Web-Server http:
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
  tags = {
    Name = "WebServers"
    Environment = "Prd"
  }
}

#Security Group for the DB
resource "aws_security_group" "Private_Web_access" {
  name        = "Private_DB_Access"
  description = "Used for Prirvate Access"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.Bastion_Security_Group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "BD"
    Environment = "Prd"
  }
}


#Apache Web-Server Test Environment
#Apache Web-Server https:
resource "aws_security_group" "Dev_Private_Web" {
  name = "Dev_Web_Private_SG"
  description = "Used for Dev Access"
  vpc_id = aws_vpc.web_vpc.id

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [
      aws_security_group.Bastion_Security_Group.id]
  }

  #Apache Web-Server http:
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      aws_security_group.Bastion_Security_Group.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [
      aws_security_group.Bastion_Security_Group.id]
  }
  tags = {
    Name = "Dev WebServers"
    Environment = "Dev"
  }
}

#-- EC2 Instance
#Get Latest AMI Image Data

#Filter out for the AMI -> Useful for Cross Region Deployments.
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}


#---- Create Bastion Host
resource "aws_instance" "bastion" {
  instance_type               =  var.Instance.micro
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = aws_subnet.bastion_Subnet.id
  #associate_public_ip_address = true
  security_groups             = [aws_security_group.Bastion_Security_Group.id]
  key_name                    = var.bastion_key
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt upgrade -y
                EOF
  tags = {
    Name = "bastion"
    name = "Bastion Host"
  }
}

#--- Assign EIP to Bastion Host
#----- Elastic IP Address for Bastion Host
resource "aws_eip" "bastion_eip" {
  vpc = true
  instance = aws_instance.bastion.id
  tags = {
    Name = "Bastion EIP"
    Environmnet = "Prd"
  }
}

#-- Web Server Placement Group
resource "aws_placement_group" "Web_Spread" {
  name     = "WebSever"
  strategy = "spread"
}


#--- Web Servers
resource "aws_instance" "Apache" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.Instance.micro
  key_name = var.Web_key
  subnet_id = aws_subnet.prd_private1.id
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  security_groups = [aws_security_group.Private_Web.id]
  placement_group = aws_placement_group.Web_Spread.id
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt upgrade -y
                sudo apt install apache2 -y
                sudo systemctl start apache2.service
                EOF
  tags = {
    Name = "Prd_Apache"
    Environment = "Prd"
  }
}

#--- WebServers
resource "aws_instance" "Apache1" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.Instance.micro
  key_name = var.Web_key
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  subnet_id = aws_subnet.prd_private2.id
  security_groups = [aws_security_group.Private_Web.id]
  placement_group = aws_placement_group.Web_Spread.id
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt upgrade -y
                sudo apt install apache2 -y
                sudo systemctl start apache2.service
                EOF
  tags = {
    Name = "Prd_Apache_1"
    Environment = "Prd"
  }
}

##--- DEV WebServers
resource "aws_instance" "Dev-Apache" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.Instance.micro
  key_name = var.Web_key
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  subnet_id = aws_subnet.prd_private2.id
  security_groups = [aws_security_group.Private_Web_access.id]
  placement_group = aws_placement_group.Web_Spread.id
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt upgrade -y
                sudo apt install apache2 -y
                sudo systemctl start apache2.service
                EOF
  tags = {
    Name = "DEV_Apache_1"
    Environment = "Dev"
  }
}

##--- DEV WebServers
resource "aws_instance" "Dev-Apache1" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.Instance.micro
  key_name = var.Web_key
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  subnet_id = aws_subnet.prd_private1.id
  security_groups = [aws_security_group.Private_Web_access.id]
  placement_group = aws_placement_group.Web_Spread.id
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt upgrade -y
                sudo apt install apache2 -y
                sudo systemctl start apache2.service
                EOF
  tags = {
    Name = "DEV_Apache"
    Environment = "Dev"
  }
}

#--- ALB For WebServer --> REF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "Apache_alb" {
  name            = "apache-alb"
  internal = false
  security_groups = [aws_security_group.Private_Web.id]
  subnets         = [aws_subnet.web_public.id,aws_subnet.web_public2.id]
  tags = {
    Name = "Apache-ALB"
    Environment = "Prd"
  }
}

#Configure Target Group
resource "aws_lb_target_group" "Apache_Group" {
  name     = "Apache-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_vpc.id
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path = "/"
    interval = 10
    port = 80
    protocol = "HTTP"
  }
}

#Create Listner
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.Apache_alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.Apache_Group.arn
    type             = "forward"
  }
}

#Target group Attachment For Apache
resource "aws_lb_target_group_attachment" "apache-web" {
  target_group_arn = aws_lb_target_group.Apache_Group.arn
  target_id = aws_instance.Apache.id
  port = 80
}

resource "aws_lb_target_group_attachment" "apache-web1" {
  target_group_arn = aws_lb_target_group.Apache_Group.arn
  target_id = aws_instance.Apache1.id
  port = 80
}
#_------------------------------------------------------------------------------------------------------


#Dev LoadBalancer
resource "aws_lb" "dev_Apache_alb" {
  name            = "dev-apache-alb"
  internal = false
  security_groups = [aws_security_group.Private_Web.id]
  subnets         = [aws_subnet.web_public.id,aws_subnet.web_public2.id]
  tags = {
    Name = "Dev-Apache-ALB"
    Environment = "Dev"
  }
}

#Configure Target Group
resource "aws_lb_target_group" "Dev_Apache_Group" {
  name     = "Dev-Apache-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_vpc.id
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path = "/"
    interval = 10
    port = 80
    protocol = "HTTP"
  }
}

#Create Listner
resource "aws_lb_listener" "dev_listener_http" {
  load_balancer_arn = aws_lb.dev_Apache_alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.Dev_Apache_Group.arn
    type             = "forward"
  }
}

#Target group Attachment For Dev Apache
resource "aws_lb_target_group_attachment" "dev_apache-web" {
  target_group_arn = aws_lb_target_group.Dev_Apache_Group.arn
  target_id = aws_instance.Dev-Apache.id
  port = 80
}

resource "aws_lb_target_group_attachment" "dev_apache-web1" {
  target_group_arn = aws_lb_target_group.Dev_Apache_Group.arn
  target_id = aws_instance.Dev-Apache1.id
  port = 80
}




#--- AutoScaling   Ref:https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group

#- Laucch Config
resource "aws_launch_configuration" "apache_config" {
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.Instance.micro
  key_name = var.Web_key
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt upgrade -y
                sudo apt install apache2 -y
                sudo systemctl start apache2.service
                EOF
  security_groups = [aws_security_group.Private_Web.id]
}

resource "aws_autoscaling_group" "apache_scale" {
  name = "Apache AutoScale"
  max_size = 2
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "EC2"
  desired_capacity = 2
  force_delete = true
  placement_group = aws_placement_group.Web_Spread.id
  launch_configuration = aws_launch_configuration.apache_config.id
  vpc_zone_identifier = [
    aws_subnet.prd_private1.id,
    aws_subnet.prd_private2.id]
}

#Adding The AutoScaling EC2 Instances into ALB Target Group
resource "aws_autoscaling_attachment" "Apache_Attachment" {
  autoscaling_group_name = aws_autoscaling_group.apache_scale.id
  alb_target_group_arn   = aws_lb_target_group.Apache_Group.arn
}



#---- Route 53 ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_query_log
#Creating Zones within Route53
resource "aws_route53_zone" "primary" {
  name = "dfoleytest.tk"
  tags = {
    Environment = "Production"
  }
}

resource "aws_route53_zone" "dev" {
  name = "dev.dfoleytest.tk"

  tags = {
    Environment = "Development Testing"
  }
}

resource "aws_route53_record" "Apache_web" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "dfoleytest.tk"
  type    = "A"

  alias {
    name                   = aws_lb.Apache_alb.dns_name
    zone_id                = aws_lb.Apache_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "Dev_Apache_web" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = "dev.dfoleytest.tk"
  type    = "A"

  alias {
    name                   = aws_lb.dev_Apache_alb.dns_name
    zone_id                = aws_lb.dev_Apache_alb.zone_id
    evaluate_target_health = true
  }
}


#----- RDS Cluster ref:  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
#RDS Subnet Assocation
resource "aws_db_subnet_group" "default" {
  name       = "db_subnet"
  subnet_ids = [aws_subnet.prd_private1.id, aws_subnet.prd_private2.id]

  tags = {
    Name = "DB Subnet"
  }
}

#Create DB Instance
resource "aws_db_instance" "Apache-DBInstance" {
  allocated_storage    = 20
  max_allocated_storage = 250
  db_subnet_group_name = aws_db_subnet_group.default.id
  engine               = "mysql"
  engine_version       = "5.6"
  instance_class       = var.Instance.DBMicro
  skip_final_snapshot  = true
  #storage_encrypted    = true
  username             = "sa"
  password             = "password123"
}

#Create AWS S3 Bucket Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "random_id" "bucket_id" {
  byte_length = 3 #Adding Random 3Numbers to the End of Bucket
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.ApacheLogs}-${random_id.bucket_id.dec}"
  acl    = "log-delivery-write"
  tags = {
    Name ="S3 logging"
    Environment = "Prd"
  }
}

resource "aws_s3_bucket" "S3Bucket" {
  bucket  = "${var.ApacheBucket}-${random_id.bucket_id.dec}"
  acl    = "private"
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
  tags = {
    Name = "S3 Apache Bucket"
  }
}

#------ECS REF: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
resource "aws_iam_role" "example" {
  name = "eks-cluster-example"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.example.name
}

resource "aws_ecr_repository" "ecr_worker" {
    name  = "worker"
}

resource "aws_ecs_cluster" "pro-ECS" {
  name = "ECSProduction"
  tags = {
    name = "ECS-Prd"
    Environment = "Production"
  }
}

resource "aws_ecs_task_definition" "service" {
  family                = "worker"
  container_definitions = "${file("JobService.json")}"

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b]"
  }
}
  resource "aws_ecs_service" "ECSapache" {
    name = "worker"
    cluster = aws_ecs_cluster.pro-ECS.id
    task_definition = aws_ecs_task_definition.service.arn
    desired_count = 3
}




