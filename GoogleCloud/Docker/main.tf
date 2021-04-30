provider "google" {
  credentials = "${file(".json")}"
  project     = "${var.Google_Project}"
  region      = "${var.Region}"
}

resource "google_compute_network" "vpc" {
 name                    = "${var.vpc_name}"
 auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
 name          = "dev"
 ip_cidr_range = "${var.subnet_cidr}"
 network       = "${var.vpc_name}"
 private_ip_google_access = true
 depends_on    = ["google_compute_network.vpc"]
 region      = "${var.Region}"
}

resource "google_compute_firewall" "firewall" {
  name    = "${var.vpc_name}-allow-ssh"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "http" {
  name    = "${var.vpc_name}-allow-http"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "https" {
  name    = "${var.vpc_name}-allow-https"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "Jenkins" {
  name    = "${var.vpc_name}-allow-Jenkins"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tomcat" {
  name    = "${var.vpc_name}-allow-tomcat"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
 source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vnc" {
  name    = "${var.vpc_name}-allow-vnc"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["5901"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "Docker_Worker1" {
  name         = "docker1" 
  machine_type = "n1-standard-1" 
  zone         = "${var.region_a}" 

  boot_disk {
    initialize_params {
    image = "ubuntu-1804-lts" 
  }
  }
   network_interface {
    subnetwork = "${google_compute_subnetwork.subnet.name}"
    access_config {}
  }
   metadata_startup_script = "${file("installdocker.sh")}"
}
 resource "google_compute_instance" "Docker_Worker2" {
  name         = "docker2" 
  machine_type = "n1-standard-1" 
  zone         = "${var.region_b}" 

  boot_disk {
    initialize_params {
    image = "ubuntu-1804-lts" 
  }
  }
   network_interface {
    subnetwork = "${google_compute_subnetwork.subnet.name}"
    access_config {}
  }
   metadata_startup_script = "${file("installdocker.sh")}"
}
resource "google_compute_instance" "Docker_Master" {
  name         = "master1" 
  machine_type = "n1-standard-1" 
  zone         = "${var.region_a}" 

  boot_disk {
    initialize_params {
    image = "ubuntu-1804-lts" 
  }
  }
   network_interface {
    subnetwork = "${google_compute_subnetwork.subnet.name}"
    access_config {}
  }
   metadata_startup_script = "${file("docker_swarm_install.sh")}"
}
resource "google_compute_instance" "Docker_Master1" {
  name         = "master2" 
  machine_type = "n1-standard-1" 
  zone         = "${var.region_b}" 

  boot_disk {
    initialize_params {
    image = "ubuntu-1804-lts" 
  }
  }
   network_interface {
    subnetwork = "${google_compute_subnetwork.subnet.name}"
    access_config {}
  }
   metadata_startup_script = "${file("installdocker.sh")}"
}


  
