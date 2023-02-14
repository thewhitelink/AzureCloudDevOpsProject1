provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "main" {
  name = "${var.prefix}-resources"
  location = var.location
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_virtual_network" "main" {
  name = "${var.prefix}-vnet1"
  address_space = ["10.0.0.0/22"]
  location = azure_rm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_public_ip" "pip" {
  name                 = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method = "Static"
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_lb" "lb" {
  name                 = "${var.prefix}-lb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  frontend_ip_configuration {
    name                 = "${var.prefix}-pip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_availability_set" "aset" {
  name = "${var.prefix}-aset"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_linux_virtual_machine" "project1" {
  for_each = {
    "${var.prefix}-web-01"
    "${var.prefix}-web-02"
    "${var.prefix}-web-03"
  }
  name = each.key
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  tags = {
    environment = "Dev"
  }
  size = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.0.4-LTS"
    version = "latest"
  }
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_managed_disk" "mdisk" {
  name = "${var.prefix}-mdisk"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags = {
  environment = "Dev"
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 10
  }
}
resource "azurerm_virtual_machine_data_disk_attachment" "mdisk" {
  managed_disk_id    = azurerm_managed_disk.mdisk.id
  virtual_machine_id = azurerm_virtual_machine.mdisk.id
  lun                = "10"
  caching            = "ReadWrite"
}