provider "azurerm" {
		client_id = var.client_id
		client_secret = var.client_secret
		tenant_id = var.tenant_id
		subscription_id = var.subscription_id
  features {}
}
# resource "azurerm_resource_group" "main" {
#   name = "${var.prefix}-resourcegroup"
#   location = var.location
#   tags = {
#     environment = "Dev"
#   }
# }
resource "azurerm_virtual_network" "vnet" {
  name = "${var.prefix}-vnet1"
  address_space = ["10.0.0.0/22"]
  location = var.location
  resource_group_name = "${var.prefix}-resourcegroup"
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${var.prefix}-resourcegroup"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "main" {
  count = "${var.vmnumber}"
  name                = "${var.prefix}-nic-0${count.index}"
  resource_group_name = "${var.prefix}-resourcegroup"
  location = var.location
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
  resource_group_name = "${var.prefix}-resourcegroup"
  location = var.location
  allocation_method = "Static"
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_lb" "lb" {
  name                 = "${var.prefix}-lb"
  resource_group_name = "${var.prefix}-resourcegroup"
  location = var.location
  frontend_ip_configuration {
    name                 = "${var.prefix}-pip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_lb_backend_address_pool" "addpool" {
  loadbalancer_id = azurerm_lb.lb.id
  name = "backendaddresspool"
}
resource "azurerm_network_interface_backend_address_pool_association" "poolassoc" {
  count = "${var.vmnumber}"
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.addpool.id
}
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-NSG-01"
  location            = var.location
  resource_group_name = "${var.prefix}-resourcegroup"

  security_rule {
    name                       = "denyInternet"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.2.0/24"
  }
  tags = {
    environment = "Dev"
  }
  security_rule {
    name                       = "allowAllInboundVNET"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  tags = {
    environment = "Dev"
  }
  security_rule {
    name                       = "allowHTTPtoVM"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "AzureLoadBalancer"
  }
  tags = {
    environment = "Dev"
  }
  security_rule {
    name                       = "alllowOutboundVNET"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_subnet_network_security_group_association" "nsgassoc" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_availability_set" "aset" {
  name = "${var.prefix}-aset"
  resource_group_name = "${var.prefix}-resourcegroup"
  location = var.location
  tags = {
    environment = "Dev"
  }
}
resource "azurerm_linux_virtual_machine" "project1" {
  name = "${var.prefix}-web-0${count.index}"
  count = "${var.vmnumber}"
  resource_group_name = "${var.prefix}-resourcegroup"
  location = var.location
  availability_set_id = azurerm_availability_set.aset.id
  tags = {
    environment = "Dev"
  }
  size = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]
  source_image_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.prefix}-resourcegroup/providers/Microsoft.Compute/images/ubuntuimage"
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
resource "azurerm_managed_disk" "mdisk" {
  name = "${var.prefix}-mdisk-0${count.index}"
  count = "${var.vmnumber}"
  resource_group_name = "${var.prefix}-resourcegroup"
  location = var.location
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 10
  tags = {
  environment = "Dev"
  }
}
resource "azurerm_virtual_machine_data_disk_attachment" "diskattach" {
  count = "${var.vmnumber}"
  managed_disk_id    = azurerm_managed_disk.mdisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.project1[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}