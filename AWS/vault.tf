#Testing Vault backend Cred Read.
provider "vault" {
  address = "http://:8200"
  token   = "s."
}

data "vault_aws_access_credentials" "creds" {
  backend = "AWS" 
  role    = "poweruser" 
}

provider "aws" {
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
  region = "eu-west-1"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "172.27.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "VPC"
  }
}
