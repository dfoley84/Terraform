# Create GCP VPC
provider "google" {
  project     = "${var.project_name}"
}

resource "google_compute_network" "management" {
 name                    = "${var.vpc_name}"
 auto_create_subnetworks = "false"
 routing_mode = "${var.routing_mode["Regional"]}"
}

resource "google_compute_network" "london_vpc" {
 name                    = "${var.vpc_name}"
 auto_create_subnetworks = "false"
 routing_mode = "${var.routing_mode["Regional"]}"
}

# Create GCP Subnet 

resource "google_compute_subnetwork" "management_subnet" {
 name          = "${var.managment_subnet_name}"
 region      = "${var.region["Zurich"]}"
 ip_cidr_range = "${var.cidrs["Zurich"]}"
 network       = google_compute_network.management.self_link
 private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet" {
 name          = "${var.subnet_name}"
 region      = "${var.region["London"]}"
 ip_cidr_range = "${var.cidrs["London"]}"
 network       = google_compute_network.london_vpc.self_link
 private_ip_google_access = true
}

# GCP Router for NAT Instance
resource "google_compute_router" "router" {
  name    = "${var.router_name}"
  network = google_compute_network.london_vpc.self_link
  region  = google_compute_subnetwork.subnet.region
}

# GCP NAT for Private Hosts
resource "google_compute_router_nat" "nat" {
  name                               = "${var.nat_name}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "${var.nat_allocation["Auto"]}"
  source_subnetwork_ip_ranges_to_nat = "${var.source_subnetwork["all_ip_ranges"]}"

  log_config {
    enable = true
    filter = "${var.log_config_error["errors"]}"
  }
}

# Peering Managment with VPC

resource "google_compute_network_peering" "management" {
  name         = "management-london"
  network      = google_compute_network.management.self_link
  peer_network = google_compute_network.london_vpc.self_link
}

resource "google_compute_network_peering" "london" {
  name         = "london-management"
  network      = google_compute_network.london_vpc.self_link
  peer_network = google_compute_network.management.self_link
}


#Firewall Rules

resource "google_compute_firewall" "ssh" {
  name    = "${var.managment_subnet_name}-allow-ssh"
  network = "${google_compute_network.management.name}"
  source_tags = ["bastion"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["${var.local_cidrs["IE_Office"]}", "${var.local_cidrs["UK_Office"]}"]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = "${google_compute_network.london_vpc.name}"
  source_tags = ["private"]
  target_tags = ["bastion"]
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}


resource "google_compute_firewall" "saltstack" {
  name    = "${var.vpc_name}-allow-saltstack"
  network = "${google_compute_network.london_vpc.name}"
  source_tags = ["bastion","private"]
  allow {
    protocol = "tcp"
    ports    = ["4505","4506"]
  }
  source_ranges = ["${var.cidrs["London"]}"]
}

resource "google_compute_firewall" "elkstack" {
  name    = "${var.vpc_name}-allow-elkstack"
  network = "${google_compute_network.london_vpc.name}"
  source_tags = ["private"]
  allow {
    protocol = "tcp"
    ports    = ["9200","5601"]
  }
  source_ranges = ["${var.cidrs["London"]}"]
}

resource "google_compute_firewall" "kibana" {
  name    = "${var.vpc_name}-allow-external-kibana"
  network = "${google_compute_network.london_vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["5601"]
  }
  source_ranges = ["${var.local_cidrs["IE_Office"]}","${var.local_cidrs["UK_Office"]}"]
}




