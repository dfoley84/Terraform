terraform {
  required_providers {
      azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
}

resource "azurerm_resource_group" "CA_Resource" {
  name     = "CA3"
  location = "Central US"
}

resource "azurerm_app_service_plan" "service-plan" {
  name = "simple-service-plan"
  location = azurerm_resource_group.CA_Resource.location
  resource_group_name = azurerm_resource_group.CA_Resource.name
  reserved = false
  sku {
    tier = "Standard"
    size = "S1"
  }
  tags = {
    environment = "Production"
  }
}

resource "azurerm_app_service" "webapp" {
  name                = "webapp"
  location            = azurerm_resource_group.CA_Resource.location
  resource_group_name = azurerm_resource_group.CA_Resource.name
  app_service_plan_id = azurerm_app_service_plan.service-plan.id
  source_control {
    repo_url           = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}

resource "azurerm_app_service_slot" "example" {
  name                = "webapp-dev"
  app_service_name    = azurerm_app_service.webapp.name
  location            = azurerm_resource_group.CA_Resource.location
  resource_group_name = azurerm_resource_group.CA_Resource.name
  app_service_plan_id = azurerm_app_service_plan.service-plan.id
  tags = {
    environment = "Development"
  }
  }
