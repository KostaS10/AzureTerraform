data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

locals {
  subscription_id = "/subscriptions/${data.azurerm_subscription.current.id}"
}

resource "azurerm_resource_group" "rg" {
  name     = var.rgName
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                       = var.kvName
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  sku_name                   = "standard"
}

resource "azurerm_log_analytics_workspace" "lawmdc" {
  name                = var.lawMDCName
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_security_center_workspace" "mdc" {
  scope        = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  workspace_id = azurerm_log_analytics_workspace.lawmdc.id
}

resource "azurerm_security_center_subscription_pricing" "mdc" {
  tier = "Standard"
}

resource "azurerm_log_analytics_solution" "mdc" {
  solution_name         = "Security"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.lawmdc.id
  workspace_name        = azurerm_log_analytics_workspace.lawmdc.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}
