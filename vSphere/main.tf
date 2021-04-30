provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
  }

  data "vsphere_datacenter" "dc" {
    name = "${var.datacenter}
  }

  data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = data.vsphere_datacenter.dc.id
  }

  data "vsphere_tag_category" "category" {
    name = "${var.category_name}"
  }

  data "vsphere_tag" "tag" {
  name        =  "${var.tag_name}"
  category_id = "${data.vsphere_tag_category.category.id}"
}
