resource "azurerm_storage_account" "storage_atividade_db" {
    name                        = "storageatividadedb"
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "atividade02 infra"
    }

    depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_linux_virtual_machine" "vm_mySQL" {
    name                  = "myVirtualMachineDB"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic_atividade_db.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDBDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myVirtualMachineDB"
    admin_username = var.user
    admin_password = var.password
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storage_atividade_db.primary_blob_endpoint
    }

    tags = {
        environment = "atividade02 infra"
    }

    depends_on = [  azurerm_resource_group.rg, 
                    azurerm_network_interface.nic_atividade_db, 
                    azurerm_storage_account.storage_atividade_db ]
}


