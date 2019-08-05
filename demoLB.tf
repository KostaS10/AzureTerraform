provider "azurerm" {
        alias = "testdeployment"
        subscription_id = "0eaaf824-a279-448e-9850-0364c21124ea"
}
resource "azurerm_resource_group" "rg" {
        name = "demoRG"
        location = "eastus"
        tags = {
                environment = "demo"
        }
}
resource "azurerm_virtual_network" "vnet" {
        name                    = "demovnet"
        address_space           = ["10.100.0.0/16"]
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"

        tags = {
                environment = "demo"
}
}
resource "azurerm_subnet" "snet" {
        name                    = "demosnet"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        virtual_network_name    = "${azurerm_virtual_network.vnet.name}"
        address_prefix          = "10.100.0.0/24"
}
resource "azurerm_network_security_group" "nsg" {
        name                    = "demonsg"
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
        name                    = "demonic"
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        network_security_group_id = "${azurerm_network_security_group.nsg.id}"

        ip_configuration {
                name            = "demoNICconfig"
                subnet_id       = "${azurerm_subnet.snet.id}"
                private_ip_address_allocation = "Static"
                private_ip_address = "10.100.0.4"
}
        tags = {
                environment = "Terraform demo"
}
}
resource "azurerm_storage_account" "storageacc" {
        name                    = "diagdemotest123123123123"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        location                = "eastus"
        account_replication_type= "LRS"
        account_tier            = "Standard"

        tags = {
                environment = "demo"

}
}
resource "azurerm_virtual_machine" "vm" {
        name                    = "demovm"
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        network_interface_ids   = ["${azurerm_network_interface.nic.id}"]
        vm_size                 = "Standard_B1s"

        storage_os_disk {
                name            = "myDisk"
                caching         = "ReadWrite"
                create_option   = "FromImage"
                managed_disk_type= "Premium_LRS"
                                disk_size_gb    = "30"
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
resource "azurerm_public_ip" "pip" {
        name                    = "pipforLB"
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        allocation_method       = "Dynamic"
}
resource "azurerm_lb" "lb" {
        name                    = "demoLB"
        location                = "eastus"
        resource_group_name     = "${azurerm_resource_group.rg.name}"

        frontend_ip_configuration {
                name            = "publicIP"
                public_ip_address_id = "${azurerm_public_ip.pip.id}"
}
}
resource "azurerm_lb_backend_address_pool" "backendpool" {
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        loadbalancer_id         = "${azurerm_lb.lb.id}"
        name                    = "backendpool"
}
resource "azurerm_lb_probe" "probe" {
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        loadbalancer_id         = "${azurerm_lb.lb.id}"
        name                    = "http-probe"
        port                    = "80"
}
resource "azurerm_lb_rule" "ruleLB" {
        resource_group_name     = "${azurerm_resource_group.rg.name}"
        loadbalancer_id         = "${azurerm_lb.lb.id}"
        name                    = "ruleLB"
        protocol                = "Tcp"
        frontend_port           = "80"
        backend_port            = "80"
        frontend_ip_configuration_name = "publicIP"
        backend_address_pool_id = "${azurerm_lb_backend_address_pool.backendpool
.id}"
        probe_id                = "${azurerm_lb_probe.probe.id}"
}
