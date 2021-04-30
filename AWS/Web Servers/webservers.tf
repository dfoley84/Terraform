# Create Web Servers on AWS

 provider "aws" {
 region = "${var.region}"
}

# Httpd security group
resource "aws_security_group" "httpd-sg" {
  name        = "httpd_sg"
  #vpc_id      = "${aws_vpc.vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "WebServers" {
  count = 2
  ami = "${var.ami_type}"
  instance_type = "${var.instance_class}"
  key_name = "${var.key_name}"
  subnet_id = "${var.aws_subnet}"
  associate_public_ip_address = true
  security_groups = ["${var.security_group}", "${aws_security_group.httpd-sg.id}"]
  key_name        = "${var.key_name}"
  tags {
    name = "Appache Web Server"
  }
  connection {
    user        = "ec2-user"
    private_key = "${file(var.private_key)}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo service httpd start",
    ]
  }
}
