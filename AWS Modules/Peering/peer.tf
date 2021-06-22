resource "aws_vpc_peering_connection" "Management_peer" {
  peer_vpc_id = var.aws_vpc_id
  vpc_id = var.management_vpc_id
  peer_region = var.region_id
}

resource "aws_vpc_peering_connection_accepter" "peering_conncetion" {
  auto_accept = true
  vpc_peering_connection_id = aws_vpc_peering_connection.Management_peer.id
}

resource "aws_route_table" "Bastion_Public_Route_Table" {
  vpc_id = var.management_vpc_id

  route { #Create a Public Route
    cidr_block = "0.0.0.0/0"
    gateway_id = var.management_igw_id
  }
  route {
    cidr_block = var.subnet_cidr.public
    vpc_peering_connection_id = aws_vpc_peering_connection.Management_peer.id
  }
  route {
    cidr_block = var.subnet_cidr.private
    vpc_peering_connection_id = aws_vpc_peering_connection.Management_peer.id
  }
  tags = {
    Name = "Management Route"
  }
}

resource "aws_route_table" "Web_Public_Route_Table" {

  vpc_id = var.aws_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  route {
    cidr_block = var.subnet_cidr.management_public
    vpc_peering_connection_id = aws_vpc_peering_connection.Management_peer.id
  }
  tags = {
    Name = "Public Route"
  }
}

resource "aws_default_route_table" "Private_Route_Table" {
  default_route_table_id = var.aws_vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.nat_id
  }
  route {
    cidr_block = var.subnet_cidr.management_private
    vpc_peering_connection_id = aws_vpc_peering_connection.Management_peer.id
  }
  tags = {
    Name = "Private Route"
  }
}

#--- Adding Subnets to Route Table
resource "aws_route_table_association" "Public_route" {
  subnet_id      = var.public_subnet_id
  route_table_id = aws_route_table.Web_Public_Route_Table.id
}

resource "aws_route_table_association" "management_route1" {
  subnet_id      = var.management_public_subnet_id
  route_table_id = aws_route_table.Bastion_Public_Route_Table.id
}

resource "aws_route_table_association" "private_route" {
  subnet_id      = var.private_subnet_id
  route_table_id =aws_default_route_table.Private_Route_Table.id
}

resource "aws_vpc_peering_connection" "Bastion-Web" {
  peer_vpc_id = var.aws_vpc_id
  vpc_id = var.management_vpc_id
  peer_region = var.region_id
}

#Accpet the Request For the Peering Connection
resource "aws_vpc_peering_connection_accepter" "peering_conncetion" {
  auto_accept = true
  vpc_peering_connection_id = aws_vpc_peering_connection.Bastion-Web.id
}
