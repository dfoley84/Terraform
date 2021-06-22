
resource "aws_security_group" "Bastion_Security_Group" {
  name        = "Bastion_SG"
  description = "Access to Bastion Host"
  vpc_id      =  var.vpc_id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "TEST Module"
  }
}
