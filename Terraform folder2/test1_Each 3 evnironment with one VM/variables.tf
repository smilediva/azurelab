variable "location" {
  default = "East US"
}

variable "environments" {
  description = "List of environments"
  type        = list(string)
}

variable "admin_username" {
  description = "VM admin username"
}

variable "admin_password" {
  description = "VM admin password"
  sensitive   = true
}
