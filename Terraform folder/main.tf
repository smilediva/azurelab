terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-subscription-provisioning"
  location = "East US"
}

resource "azurerm_storage_account" "sa" {
  name                     = "subprovisioning${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_management_group" "mg" {
  name         = "mg-subscription-provisioning"
  display_name = "Subscription Provisioning Management Group"
}

resource "azurerm_management_group_subscription_association" "association" {
  management_group_id = azurerm_management_group.mg.id
  subscription_id     = data.azurerm_client_config.current.subscription_id
}
