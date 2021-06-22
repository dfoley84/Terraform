variable "aws_vpc_id" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}
variable "management_vpc_id" {}
variable "management_public_subnet_id" {}
variable "region_id" {}
variable "management_igw_id" {}
variable "igw_id" {}
variable "nat_id" {}


variable "subnet_cidr" {
  type = map(string)
  default = {
    public = "172.27.1.0/24"
    private = "172.27.2.0/24"
    management_public = "172.26.1.0/24"
    management_private = "172.26.2.0/24"
    management_private1 = "172.26.3.0/24"

  }
}


