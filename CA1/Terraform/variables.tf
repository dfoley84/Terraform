variable "vpc_cdir" {
  type = "map"
  default = {
    "bastion_vpc" = "172.27.0.0/16"
    "web_vpc" = "172.26.0.0/16"
  }
}

variable "subnet_cidr" {
  type = "map"
  default = {
    "bastion_Subnet" = "172.27.1.0/24"
    "bastion_Subnet2" = "172.27.2.0/24"
    "public_subnet1" = "172.26.1.0/24"
    "public_subnet2" = "172.26.2.0/24"
    "private_subnet1" = "172.26.10.0/24"
    "private_subnet2" = "172.26.11.0/24"
  }
}

variable "FailOver_subnet_cidr" {
  type = "map"
  default = {
    "public_subnet1" = "172.28.1.0/24"
    "public_subnet2" = "172.28.2.0/24"
    "private_subnet1" = "172.28.10.0/24"
    "private_subnet2" = "172.28.11.0/24"
  }
}

variable "Production_Region" {
  type = string
  default = "eu-west-1"
}

variable "FailOver_Region" {
  type = string
  default = "eu-west-2"
}

variable "bastion_key" {
  type = string
  default = "bastion"
}

variable "Web_key" {
  type = string
  default = "webservers"
}

variable "ApacheBucket" {
  type = string
  default = "apaches3"
}

variable "ApacheLogs" {
  type = string
  default = "apachelog"
}

variable "ec2policy" {
  type = string
  default = "EC2_Role"
}

variable "Devpolicy" {
  type = string
  default = "Developer_Role"
}

variable "Instance" {
  type = "map"
  default = {
    "micro" = "t2.micro"
    "small" = "t2.small"
    "medium" = "t2.medium"
    "large" = "t2.large"
    "DBMicro" = "db.t2.micro"
  }
}