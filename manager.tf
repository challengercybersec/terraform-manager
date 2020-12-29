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


#Vnet Config

resource "azurerm_virtual_network" "Vnet-Manager" {
  name                = "vnet-manager"
  location            = var.region
  resource_group_name = azurerm_resource_group.RG-ManagerMDS.name
  address_space       = ["10.4.20.0/24"]

  tags = {
    owner = "Terraform Automation"
  }
}


#Subnet Creation

resource "azurerm_subnet" "Subnet-Manager" {
  name                 = "subnet-manager"
  resource_group_name  = azurerm_resource_group.RG-ManagerMDS.name
  virtual_network_name = azurerm_virtual_network.Vnet-Manager.name
  address_prefixes     = ["10.4.20.0/25"]
}



#NSG ASSOCIATIONS
resource "azurerm_subnet_network_security_group_association" "assosiation1" {
  subnet_id                 = azurerm_subnet.Subnet-Manager.id
  network_security_group_id = azurerm_network_security_group.NSG-Manager.id
}



#Public IP

resource "azurerm_public_ip" "managerip" {
  name                = "acceptanceTestPublicIp1"
  location            = var.region
  resource_group_name = azurerm_resource_group.RG-ManagerMDS.name
  allocation_method   = "Static"

  tags = {
    owner = "Terraform Automation"
  }
}


#Network Interface Configuration

resource "azurerm_network_interface" "Manager-Nic" {
  name                = "manager-nic"
  location            = var.region
  resource_group_name = azurerm_resource_group.RG-ManagerMDS.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-Manager.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.managerip.id
 }

  tags = {
    owner = "Terraform Automation"
  }
}


#Storage Account Configuration
resource "azurerm_storage_account" "stgacc_mds" {
  name                     = "storageaccountmds"
  resource_group_name      = azurerm_resource_group.RG-ManagerMDS.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    owner = "Terraform Automation"
  }
}






