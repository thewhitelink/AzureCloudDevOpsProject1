provider "azurerm" {
		client_id = var.client_id
		client_secret = var.client_secret
		tenant_id = var.tenant_id
		subscription_id = var.subscription_id
  features {}
}
resource "azurerm_resource_group" "main" {
  name = "${var.prefix}-resourcegroup"
  location = var.location
  tags = {
    environment = "Dev"
  }
}