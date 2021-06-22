provider "aws" {
  region = var.Production_Region
  profile = "production"
}

module "Network" {
  source = "./Network"
}

module "Peering" {
  source = "./Peering"
  aws_vpc_id = module.Network.vpc_id
  igw_id = module.Network.vpc_igw_id
  management_igw_id = module.Network.management_vpc_igw_id
  management_public_subnet_id = module.Network.public_subnet_id
  management_vpc_id = module.Network.management_vpc_id
  nat_id = module.Network.nat_id
  private_subnet_id = module.Network.private_subnet_id
  public_subnet_id = module.Network.public_subnet_id
  region_id = var.Production_Region

}
module "Security" {
  source = "./Security"
  vpc_id = module.Network.vpc_id
}

module "EC2" {
  source = "./EC2"
  subnet_id = module.Network.public_subnet_id
  security_id = module.Security.security_id
}