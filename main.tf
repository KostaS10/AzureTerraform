resource "azurerm_resource_group" "rg" {
  name     = var.rgName
  location = var.location
}