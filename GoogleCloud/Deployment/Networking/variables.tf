variable "project_name"{}
variable "vpc_name" {}
variable "subnet_name"{}
variable "router_name"{}
variable "nat_name"{}

variable "routing_mode" {
    type = "map"
    default = {
        "Regional" = "REGIONAL"
        "Global" = "GLOBAL"
    }
}
variable "region" {
    type = "map"
    default = {
        "Belgium" = "europe-west1"
        "London"  = "europe-west2"
        "Frankfurt" = "europe-west3"
        "Eemshaven" = "europe-west4"
        "Zurich" = "europe-west6"
    }
}
variable "instance_n1" {
    type = "map"
    default = {
        "n1-standard-1" = "n1-standard-1"
        "n1-standard-2"  = "n1-standard-2"
        "n1-standard-4" = "n1-standard-4"
        "n1-standard-8" = "n1-standard-8"
        "n1-standard-16" = "n1-standard-16"
    }
}
variable "instacne_n2" {
    type = "map"
    default = {
        "n2-standard-1" = "n2-standard-1"
        "n2-standard-2"  = "n2-standard-2"
        "n2-standard-4" = "n2-standard-4"
        "n2-standard-8" = "n2-standard-8"
        "n2-standard-16" = "n2-standard-16"
    }
}
variable "nat_allocation" {
    type = "map"
    default = {
        "Auto" = "AUTO_ONLY"
        "Manual" = "MANUAL_ONLY"
    }
}
variable "source_subnetwork" {
    type = "map"
    default = {
        "all_ip_ranges" = "ALL_SUBNETWORKS_ALL_IP_RANGES"
        "all_primary_ranges" = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"
    }
}
variable "log_config_error" {
    type = "map"
    default = {
        "errors" = "ERRORS_ONLY"
        "all" = "ALL"
        "translation" = "TRANSLATIONS_ONLY"
    }
}

variable "cidrs" {
  type = "map" 
  default = {
      Belgium   = "10.0.1.0/24"
      London    = "10.0.2.0/24"
      Frankfurt = "10.0.3.0/24"
     Eemshaven = "10.0.4.0/24"
     Zurich    = "10.0.5.0/24"
  }
}

variable "local_cidrs" {
  type = "map" 
  default = {
      IE_Office = "0.0.0.0/0"
      UK_Office = "0.0.0.0/0"
      DE_Office = "0.0.0.0/0"
  }
}
