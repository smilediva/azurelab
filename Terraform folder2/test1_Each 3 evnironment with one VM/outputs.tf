output "vm_public_ips" {
  value = {
    for env in var.environments :
    env => azurerm_public_ip.pip[env].ip_address
  }
}
