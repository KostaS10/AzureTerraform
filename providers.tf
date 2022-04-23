terraform {
  required_version = "=1.1.9"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=3.3.0"
    }
  }
  backend "azurerm"{
	resource_group_name = "terraform"
	storage_account_name = "terraformsgkosta"
	container_name = "tfstate"
	key = "terraform.tfstate"
}
}

provider "azurerm" {
    features {}
    use_microsoft_graph = true
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
}
