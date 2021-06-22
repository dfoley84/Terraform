variable "vpc_cdir" {
  type = string
  default = {
    web = "172.27.0.0/16"
    managment = "172.26.0.0/16"
  }
}

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

variable "Production_Region" {
  type = string
  default = "eu-west-1"
}

variable "bastion_key" {
  type = string
  default = "bastion"
}

variable "Web_key" {
  type = string
  default = "webservers"
}

