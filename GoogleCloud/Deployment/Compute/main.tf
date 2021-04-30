provider "google" {
  project     = "${var.project_name}"
}

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "${var.instance_n1["n1-standard-1"]}"
  zone         = "${var.zones["London"]}"
  tags = ["bastion"]

  boot_disk {
    initialize_params {
    image = "centos-7" 
    size = "60"
    }
  }
   network_interface {
    subnetwork = "${var.subnet_name}"
    access_config {
        //External IP
    } 
  }
    metadata_startup_script = "${file("startup.sh")}"
}

resource "google_compute_instance" "kibana" {
  name         = "Kibana"
  machine_type = "${var.instance_n1["n1-standard-1"]}"
  zone         = "${var.zones["London"]}"
  tags = ["private","kibana"]

  boot_disk {
    initialize_params {
    image = "centos-7" 
    size = "60"
    }
  }
   network_interface {
    subnetwork = "${var.subnet_name}"
  }
    metadata_startup_script = "${file("startup.sh")}"
}

resource "google_compute_instance" "elasticsearch" {
  name         = "Node1"
  machine_type = "${var.instance_n1["n1-standard-1"]}"
  zone         = "${var.zones["London"]}"
  tags = ["private","elasticsearch"]

  boot_disk {
    initialize_params {
    image = "centos-7" 
    size = "60"
    }
  }
   network_interface {
    subnetwork = "${var.subnet_name}"
  }
    metadata_startup_script = "${file("startup.sh")}"
}
