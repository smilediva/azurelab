provider "azurerm" {
  features {}
}

# --------------------------
# Resource Groups
# --------------------------
resource "azurerm_resource_group" "rg" {
  for_each = toset(var.environments)

  name     = "rg-${each.key}"
  location = var.location
}

# --------------------------
# Virtual Network
# --------------------------
resource "azurerm_virtual_network" "vnet" {
  for_each            = toset(var.environments)
  name                = "vnet-${each.key}"
  address_space       = ["10.${index(var.environments, each.key)}.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
}

# --------------------------
# Subnet
# --------------------------
resource "azurerm_subnet" "subnet" {
  for_each             = toset(var.environments)
  name                 = "subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = ["10.${index(var.environments, each.key)}.1.0/24"]
}

# --------------------------
# Public IP
# --------------------------
resource "azurerm_public_ip" "pip" {
  for_each            = toset(var.environments)
  name                = "pip-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  allocation_method   = "Static"
}

# --------------------------
# Network Interface
# --------------------------
resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.environments)
  name                = "nic-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

# --------------------------
# Windows Virtual Machine
# --------------------------
resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = toset(var.environments)
  name                = "vm-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]
  size = "Standard_D2s_V3"

  admin_username = var.admin_username
  admin_password = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  tags = {
    environment = each.key
  }
}