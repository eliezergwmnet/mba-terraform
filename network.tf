resource "azurerm_virtual_network" "vnet_atividade" {
    name                = "myVnet"
    address_space       = ["10.80.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = "atividade02 infra"
    }

    depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_subnet" "subnet_atividade" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet_atividade.name
    address_prefixes       = ["10.80.4.0/24"]

    depends_on = [  azurerm_resource_group.rg, 
                    azurerm_virtual_network.vnet_atividade ]
}

resource "azurerm_network_security_group" "sg_atividade" {
    name                = "myNetworkSecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPInbound"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "mysql"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }    
    
    tags = {
        environment = "atividade02 infra"
    }

    depends_on = [ azurerm_resource_group.rg ]
}