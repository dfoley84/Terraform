/*
* main.tf
*/

provider "google" {}

module "kubernetes-cluster" {
  source     = "tsadoklf/kubernetes-cluster/google"
  version    = "1.0.0"
  subnetwork = ""
  network    = ""
  # The cluster name.
  name = ""
  zone = ""
}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "1.5.0"
  # The ID of the project where this VPC will be created
  project_id = ""
  # The list of subnets being created
  subnets = []
  # The name of the network being created
  network_name = ""
}

module "cloud-nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "1.2.0"
  # The region to deploy to
  region = ""
  # The project ID to deploy to
  project_id = ""
  # The name of the router in which this NAT will be configured. Changing this forces a new NAT to be created.
  router = ""
}
