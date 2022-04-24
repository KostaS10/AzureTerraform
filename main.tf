data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.rgName
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name = var.kvName
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = true
  soft_delete_retention_days  = 7
}