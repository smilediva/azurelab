#Specify the provider and version
terraform {
	required_providers {
		azurerm = {
			source  = "hashicorp/azurerm"
			version = "~>4.0"
		}
	}
}

# Configure the Microsoft azure provide
provider "azurerm" {
	features {}
}

# Create a RG

resource "azurerm_resource_group" "contoso_rg" {
	name     = "test_rg"
	location = "UK South"
	tags = {
		cost_center = "MS research"
	}
}