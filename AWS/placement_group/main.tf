data "aws_ami" "server_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }
}

resource "aws_placement_group" "cluster" {
  name     = "Dublin_placementGroup"
  strategy = "cluster"
}


resource "aws_key_pair" "tf_auth" {
  key_name   = "${var.key_name}"
}

data "template_file" "user-init" {
  count    = 2
  template = "${file("${path.module}/userdata.tpl")}"

  vars {
    firewall_subnets = "${element(var.subnet_ips, count.index)}"
  }
}




resource "aws_instance" "server" {
  count         = "${var.instance_count}"
  instance_type = "${var.instance_type}"
  ami           = "${data.aws_ami.server_ami.id}"
  placement_group = "${aws_placement_group.cluster.id}"
  tags {
    Name = "jenkins-${count.index +1}"
  }
  key_name               = "${aws_key_pair.tf_auth.id}"
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = "${element(var.subnets, count.index)}"
  user_data              = "${data.template_file.user-init.*.rendered[count.index]}"
}
