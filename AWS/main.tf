provider "aws" {
  region  = "${var.aws_region_Dev}"
  profile = "${var.aws_profile_Dev}"
}

resource "aws_instance" "" {
  ami             = "${var.dev-Ubuntu18}"
  instance_type   = "${var.instance_Zabbix}"
  key_name        = "${var.keypair-zabbix}"
  subnet_id       = "${var.DEV-SharedService-VA-private-az2}"
  security_groups = ["${var.ElasticSearchSG}"]
    root_block_device {
    volume_size = "700"
  }
   user_data = <<-EOF
                #!/bin/bash
                sudo hostnamectl set-hostname 
                sudo apt update -y 
                sudo apt upgrade -y
                wget -O install_salt.sh https://bootstrap.saltstack.com
                sudo sh install_salt.sh -A 
                EOF
  tags {
    name = ""
    function = "ElasticSearch PoC"
  }
}

resource "aws_instance" "" {
  ami             = "${var.dev-Ubuntu18}"
  instance_type   = "${var.instance_Zabbix}"
  key_name        = "${var.keypair-zabbix}"
 subnet_id       = "${var.DEV-SharedService-VA-private-az2}"
  security_groups = ["${var.ElasticSearchSG}"]
    root_block_device {
    volume_size = "700"
  }
   user_data = <<-EOF
                #!/bin/bash
                sudo hostnamectl set-hostname 
                sudo apt update -y 
                sudo apt upgrade -y
                wget -O install_salt.sh https://bootstrap.saltstack.com
                sudo sh install_salt.sh -A 
                EOF
  tags {
    name = ""
    function = "ElasticSearch PoC"
  }
}

resource "aws_instance" "" {
  ami             = "${var.dev-Ubuntu18}"
  instance_type   = "${var.instance_Zabbix}"
  key_name        = "${var.keypair-zabbix}"
 subnet_id       = "${var.DEV-SharedService-VA-private-az2}"
  security_groups = ["${var.ElasticSearchSG}"]
    root_block_device {
    volume_size = "700"
  }
   user_data = <<-EOF
                #!/bin/bash
                sudo hostnamectl set-hostname 
                sudo apt update -y 
                sudo apt upgrade -y
                wget -O install_salt.sh https://bootstrap.saltstack.com
                sudo sh install_salt.sh -A 
                EOF
  tags {
    name = ""
    function = "ElasticSearch PoC"
  }
}

resource "aws_instance" "" {
  ami             = "${var.dev-Ubuntu18}"
  instance_type   = "${var.instance_Zabbix}"
  key_name        = "${var.keypair-zabbix}"
  subnet_id       = "${var.DEV-SharedService-VA-private-az2}"

  security_groups = ["${var.ElasticSearchSG}"]
    root_block_device {
    volume_size = "700"
  }
  user_data = <<-EOF
                #!/bin/bash
                sudo hostnamectl set-hostname 
                sudo apt update -y 
                sudo apt upgrade -y
                wget -O install_salt.sh https://bootstrap.saltstack.com
                sudo sh install_salt.sh -A 
                EOF
  tags {
    name = ""
    function = "ElasticSearch PoC"
  }
}
