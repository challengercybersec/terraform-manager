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



#Vnet Subnet Config

resource "azurerm_virtual_network" "Vnet-Manager" {
  name                = "vnet-manager"
  location            = var.region
  resource_group_name = azurerm_resource_group.RG-ManagerMDS.name
  address_space       = ["10.4.20.0/24"]

  subnet {
    name           = "subnet-manager"
    address_prefixes = ["10.4.20.0/25"]
  }

  tags = {
    owner = "Terraform Automation"
  }
}
