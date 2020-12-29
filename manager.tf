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
resource "azurerm_storage_account" "stgaccmds" {
  name                     = "pablobdeblob"
  resource_group_name      = azurerm_resource_group.RG-ManagerMDS.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    owner = "Terraform Automation"
  }
}


#Virtual Machine Config


resource "azurerm_linux_virtual_machine" "Manager" {
  admin_username      = "administratorjeff"
  admin_password      = "Password1234"
  computer_name       = "jeff"
  name                = "MDS_Manager"
  resource_group_name = azurerm_resource_group.RG-ManagerMDS.name
  location            = var.region
  size                = "Standard_D3_v2"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.Manager-Nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
#    create_option        = "FromImage"
#    manage_disk_type     = "Standard_LRS"
  }

  source_image_reference {
    publisher = "checkpoint"
    offer     = "check-point-cg-r8040"
    sku       = "mgmt-byol"
    version   = "latest"
  }
   plan {
        name = "mgmt-byol"
        publisher = "checkpoint"
        product = "check-point-cg-r8040"
        }



#  os_profile_linux_config {
#    }

  boot_diagnostics {
#        enabled = "true"
#        storage_uri = azurerm_storage_account.stgacc_mds.primary_blob_endpoint
    }

/*
  os_profile {
        admin_username = "cloudmss"
#        custom_data = base64encode(data.template_file.manager.rendered)
#Script .sh que ejecuta esas cositas

 }
*/

  tags = {
    owner = "Terraform Automation"
    x-chkp-template = "checkpoinmanager"
    x-chkp-management = "tfmanager"
  }
}


output "publicamanager" {
 value = azurerm_public_ip.managerip
}


