#Creating Server from Clone Instance 


provider "vsphere" {
       allow_unverified_ssl = true
}
 
data "vsphere_datacenter" "dc" {
  name = "${var.Server}"
}

resource "vsphere_folder" "Terraform_Folder" {
    datacenter = "${var.vphere_datacenter}"
    path = "${var.vRealizeFolder}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.storage}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "vlan105" {
  name          = "${var.vlan105}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "Production Server" {
    name =  "${var.prdouction_prefix} + Test123"
    folder = "${vsphere_folder.Terraform_Folder.path}"
    cluster = "${var.production_cluster}"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"
    
    vcpu = 4
    memory = 12096  
  
network_interface{
    network_id  = "${data.vsphere_network.vlan105.id}"
    adapter_type = "vmxnet"
    ipv4_address       = "10.40.105.225"
    ipv4_prefix_length = "24"
    ipv4_gateway       = "10.40.105.100"
}
disk {
    template = "${var.Windows}"
    eagerly_scrub    = false
    thin_provisioned = true
}
}



