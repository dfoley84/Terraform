
terraform {
  backend "s3" {
    bucket = ""
    key    = "/terraform.tfstate"
    region = ""
    encrypt = true
  }
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.11.17"
    }
  }
}

provider "elasticstack" {
    kibana {
        api_key = var.kibana_api_key
        endpoints = [var.kibana_endpoint]
    }
}


