#Definicion de variables importadas

variable "rsgname" {
  type = string
}
variable "region" {
  type = string
}



#Creacion de resource group
resource "azurerm_resource_group" "RG-ManagerMDS" {
  name     = var.rsgname
  location = var.region

  tags = {
    owner = "Terraform Automation"
  }
}


#Create Network Security Group

resource "azurerm_network_security_group" "NSG-Manager" {
  name                = "nsg-manager"
  location            = var.region
  resource_group_name = azurerm_resource_group.RG-ManagerMDS.name

  security_rule {
    name                       = "allowall"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    owner = "Terraform Automation"
  }
}


#Vnet Subnet Config

resource "azurerm_virtual_network" "Vnet-Manager" {
  name                = "vnet-manager"
  location            = var.region
  resource_group_name = azurerm_resource_group.RG-ManagerMDS.name
  address_space       = ["10.4.20.0/24"]

  subnet {
    name           = "subnet-manager"
    address_prefix = "10.4.20.0/25"
    security_group = azurerm_network_security_group.NSG-Manager.id
  }

  tags = {
    owner = "Terraform Automation"
  }
}


#NSG ASSOCIATIONS
/*
resource "azurerm_subnet_network_security_group_association" "assosiation1" {
  subnet_id                 = azurerm_virtual_network.Vnet-Manager.subnet.id
  network_security_group_id = azurerm_network_security_group.NSG-Manager.id
}

*/

