# This file was autogenerated by the BETA 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/from-1.5/variables#type-constraints for more info.
# "timestamp" template function replacement
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
source "amazon-ebs" "autogenerated_1" {
  access_key    = "${var.aws_access_key}"
  ami_name      = "Ubuntu_elasticSearch-${local.timestamp}"
  instance_type = "t2.micro"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 60
    volume_type           = "gp2"
  }
  region     = "us-east-1"
  secret_key = "${var.aws_secret_key}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "shell" {
    inline = ["sleep 30", "apt-add-repository ppa:ansible/ansible -y", "/usr/bin/apt-get update", "/user/bin/apt upgrade -y", "/usr/bin/apt-get -y install ansible"]
  }
  provisioner "shell" {
    inline = ["sleep 30", "ansible-galaxy install geerlingguy.clamav -y"]
  }
  provisioner "ansible-local" {
    playbook_file = "./Ansible/domain.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "./Ansible/java.yml"
  }
  provisioner "ansible-local" {
    playbook = "./Ansible/filebeat.yml"
  }
  provisioner "ansible-local" {
    playbook = "./Ansible/metricbeat.yml"
  }
}
