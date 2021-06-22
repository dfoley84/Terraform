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

resource "aws_instance" "bastion" {
  instance_type               = var.Instance.micro
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = var.subnet_id
  security_groups = [var.security_id]
  associate_public_ip_address = true
  tags = {
    Name = "bastion"
    name = "Bastion Host"
  }
}
