terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "pulse_rg" {
  name     = "rg-cloudpulse-prod"
  location = "eastus2"
}

# Random String 
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# The "Container Instance"
resource "azurerm_container_group" "pulse_backend" {
  name                = "aci-cloudpulse-backend"
  location            = azurerm_resource_group.pulse_rg.location
  resource_group_name = azurerm_resource_group.pulse_rg.name
  ip_address_type     = "Public"
  dns_name_label      = "cloudpulse-api-${random_string.suffix.result}"
  os_type             = "Linux"

  container {
    name   = "cloudpulse-backend"
    # Using a Microsoft test image first to verify deployment works
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld" 
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}

# Output URL
output "backend_url" {
  value = "http://${azurerm_container_group.pulse_backend.fqdn}"
}

# The Registry
resource "azurerm_container_registry" "pulse_acr" {
  name                = "acrcloudpulse${random_string.suffix.result}" # Must be unique
  resource_group_name = azurerm_resource_group.pulse_rg.name
  location            = azurerm_resource_group.pulse_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# name of the registry in the terminal
output "acr_name" {
  value = azurerm_container_registry.pulse_acr.name
}