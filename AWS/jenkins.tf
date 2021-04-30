#compute
provider "aws" {
 region = "${var.region}"
}


resource "aws_instance" "Ansible" {
  ami = "${var.ami_type}"
  instance_type = "${var.instance_class}"
  key_name = "${var.key_name}"
  subnet_id = "${var.aws_subnet}"
  associate_public_ip_address = true
  security_groups = ["${var.security_group}"]
  tags {
        Name = "Ansible"
        }
}


resource "aws_instance" "Jenkin" { 
  ami = "${var.ami_type}" 
  instance_type = "${var.instance_class}"
  key_name = "${var.key_name}"
  subnet_id = "${var.aws_subnet}"
  associate_public_ip_address = true
  security_groups = ["${var.security_group}"] 
 
  tags {
	Name = "Jenkins"
	} 
} # End of AWS_Instance

resource "aws_s3_bucket" "code" {
	bucket = "${var.S3}_code1114"
	acl = "private"
	tags {
		Name = "Ansible Code Bucket"
	     }
} # End of AWS S3 Bucket.
