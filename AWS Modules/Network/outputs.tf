
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "management_vpc_id" {
  value = aws_vpc.management_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "management_private_subnet_id" {
  value = aws_subnet.management_private.id
}

output "management_private1_subnet_id" {
  value = aws_subnet.management_private1.id
}

output "vpc_igw_id"{
  value = aws_internet_gateway.vpc_igw.id
}

output "management_vpc_igw_id"{
  value = aws_internet_gateway.management_vpc_igw.id
}

output "eip_id" {
  value = aws_eip.elastic_Nat.id
}

output "management_eip_id" {
  value = aws_eip.management_elastic_ip.id
}


output "nat_id" {
  value = aws_nat_gateway.NAT.id
}

output "management_nat_id" {
  value = aws_nat_gateway.Managment_NAT.id
}
