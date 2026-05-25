
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

variable "location" {
	type    = string
	default = "East US"
}

variable "resource_group_name" {
	type    = string
	default = "rg-sample-webapp"
}

variable "app_service_plan_name" {
	type    = string
	default = "asp-sample-webapp"
}

variable "webapp_name" {
	type    = string
	default = "sample-webapp-001"
}

resource "azurerm_resource_group" "rg" {
	name     = var.resource_group_name
	location = var.location
}

resource "azurerm_app_service_plan" "asp" {
	name                = var.app_service_plan_name
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name
	kind                = "Linux"

	sku {
		tier = "Basic"
		size = "B1"
	}

	reserved = true # required for Linux
}

resource "azurerm_app_service" "webapp" {
	name                = var.webapp_name
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name
	app_service_plan_id = azurerm_app_service_plan.asp.id

	site_config {
		linux_fx_version = "DOTNETCORE|6.0" # change runtime as needed
	}

	app_settings = {
		"WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
		"WEBSITE_RUN_FROM_PACKAGE"            = "1"
	}

	tags = {
		environment = "dev"
		created_by  = "terraform"
	}
}

output "webapp_default_hostname" {
	description = "Default hostname of the App Service"
	value       = azurerm_app_service.webapp.default_site_hostname
}
