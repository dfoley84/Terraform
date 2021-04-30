#-----networking/outputs.tf----

output "public_subnet_1" {
  value = "${aws_subnet.wp_public1_subnet.id}"
}
output "public_subnet_2" {
  value = "${aws_subnet.wp_public2_subnet.id}"
}

output "private_subnet_1" {
  value = "${aws_subnet.wp_private1_subnet.id}"
}

output "private_subnet_2" {
  value = "${aws_subnet.wp_private2_subnet.id}"
}


output "public_sg" {
  value = "${aws_security_group.wp_dev_sg.id}"
}

output "public1_sg" {
  value = "${aws_security_group.wp_public_sg.id}"
}
output "private_sg" {
  value = "${aws_security_group.wp_private_sg.id}"
}