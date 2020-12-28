variable "rsgname" {
  type = string
}
variable "region" {
  type = string
}



resource "azurerm_resource_group" "RG-ManagerMDS" {
  name     = var.rsgname
  location = var.region
}
