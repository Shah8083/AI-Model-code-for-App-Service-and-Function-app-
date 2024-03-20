# Define the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
# Define the Resource Group
resource "azurerm_resource_group" "AI-Test" {
  name     = "AI-vm"
  location = "West Europe"
}
# Define the Virtual Network
resource "azurerm_virtual_network" "AI-vnet" {
  name                = "AI-vm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.AI-Test.location
  resource_group_name = azurerm_resource_group.AI-Test.name
}
# Define the Azure Subnet
resource "azurerm_subnet" "AI-Subnet" {
  name                 = "AI-Subnet-vm"
  resource_group_name  = azurerm_resource_group.AI-Test.name
  virtual_network_name = azurerm_virtual_network.AI-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "AI-infra" {
  name                = "AI-Interface-vm"
  location            = azurerm_resource_group.AI-Test.location
  resource_group_name = azurerm_resource_group.AI-Test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.AI-Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "AI-vm" {
  name                = "AI-machine"
  resource_group_name = azurerm_resource_group.AI-Test.name
  location            = azurerm_resource_group.AI-Test.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.AI-infra.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}