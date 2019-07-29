provider "azurerm" {

        subscription_id = "0eaaf824-a279-448e-9850-0364c21124ea"
}
resource "azurerm_resource_group" "rg" {
        name = "testRG"
        location = "eastus"
        tags = {
                environment = "Terraform demo"
        }
}
resource "azurerm_virtual_network" "vnet" {
        name                    = "demoVNET"
        address_space           = ["10.0.0.0/16"]
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"

        tags = {
                environment = "Terraform demo"
}
}
resource "azurerm_subnet" "snet" {
        name                    = "demoSNET"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        virtual_network_name    = "${azurerm_virtual_network.vnet.name}"
        address_prefix          = "10.0.0.0/24"
}
resource "azurerm_public_ip" "pip" {
        name                    = "demoPIP"
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        allocation_method       = "Dynamic"

        tags = {
                environment = "Terraform demo"
}
}
resource "azurerm_network_security_group" "nsg" {
        name                    = "demoNSG"
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"

        security_rule {
        name                    = "SSHAllowIn"
        priority                = "1001"
        direction               = "Inbound"
        access                  = "Allow"
        protocol                = "Tcp"
        source_port_range       = "*"
        destination_port_range  = "22"
        source_address_prefix   = "109.122.86.198"
        destination_address_prefix = "*"
}
}
resource "azurerm_network_interface" "nic" {
        name                    = "demoNIC"
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        network_security_group_id = "${azurerm_network_security_group.nsg.id}"

        ip_configuration {
                name            = "demoNICconfig"
                subnet_id       = "${azurerm_subnet.snet.id}"
                private_ip_address_allocation = "Dynamic"
                public_ip_address_id = "${azurerm_public_ip.pip.id}"
}
        tags = {
                environment = "Terraform demo"
}
}
resource "azurerm_storage_account" "storageacc" {
        name                    = "diagdemotest123123123"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        location                = "eastus"
        account_replication_type= "LRS"
        account_tier            = "Standard"

        tags = {
                environment = "Terraform demo"

}
}
resource "azurerm_virtual_machine" "vm" {
        name                    = "demoVM"
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        network_interface_ids   = ["${azurerm_network_interface.nic.id}"]
        vm_size                 = "Standard_DS1_v2"

        storage_os_disk {
                name            = "myDisk"
                caching         = "ReadWrite"
                create_option   = "FromImage"
                managed_disk_type= "Premium_LRS"
}
        storage_image_reference {
                publisher       = "OpenLogic"
                offer           = "CentOS"
                sku             = "7.5"
                version         = "latest"
    }
        os_profile {
        computer_name           = "demoVM"
        admin_username          = "kosta"
        admin_password          = "Demopassword72"
}
        os_profile_linux_config {
                disable_password_authentication = false
  }
}
