resource "azurerm_network_interface" "nic_atividade_db" {
    name                      = "myNICDB"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "myNicConfigurationDB"
        subnet_id                     = azurerm_subnet.subnet_atividade.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.80.4.10"
        public_ip_address_id          = azurerm_public_ip.publicip_atividade_mysql.id
    }

    tags = {
        environment = "atividade02 infra"
    }

    depends_on = [  azurerm_resource_group.rg, 
                    azurerm_subnet.subnet_atividade,
                    azurerm_public_ip.publicip_atividade_mysql ]
}

resource "azurerm_public_ip" "publicip_atividade_mysql" {
    name                         = "myPublicIPMySQL"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Static"
    idle_timeout_in_minutes = 30

    tags = {
        environment = "atividade02 infra",
        tool = "ansible"
    }

    depends_on = [ azurerm_resource_group.rg ]
}


resource "azurerm_network_interface_security_group_association" "nicsq_atividade_db" {
    network_interface_id      = azurerm_network_interface.nic_atividade_db.id
    network_security_group_id = azurerm_network_security_group.sg_atividade.id

    depends_on = [  azurerm_network_interface.nic_atividade_db, 
                    azurerm_network_security_group.sg_atividade ]
}
