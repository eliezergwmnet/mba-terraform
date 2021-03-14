resource "azurerm_storage_account" "storage_atividade_db" {
    name                        = "storageauladb"
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_linux_virtual_machine" "vm_mySQL" {
    name                  = "myVMDB"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic_aula_db.id]
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

    computer_name  = "myvmdb"
    admin_username = var.user
    admin_password = var.password
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storage_atividade_db.primary_blob_endpoint
    }

    tags = {
        environment = "aula infra"
    }

    depends_on = [  azurerm_resource_group.rg, 
                    azurerm_network_interface.nic_aula_db, 
                    azurerm_storage_account.storage_atividade_db ]
}


resource "azurerm_public_ip" "publicip_mysqlserver" {
    name                         = "myPublicIPAnsible"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Static"
    idle_timeout_in_minutes = 30

    tags = {
        environment = "aula infra"
    }

    depends_on = [ azurerm_resource_group.rg ]
}


data "azurerm_public_ip" "ip_mysqlserver" {
  name                = azurerm_public_ip.publicip_mysqlserver.name
  resource_group_name = azurerm_resource_group.rg.name
}


resource "null_resource" "deploy" {
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = data.azurerm_public_ip.ip_mysqlserver.ip_address
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y mysql-server-5.7",
            "service mysql restart"            
        ]
    }
}

#            "cat /mysql/mysqld.cnf > /etc/mysql/mysql.conf.d/mysqld.cnf",