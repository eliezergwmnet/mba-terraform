
resource "azurerm_storage_account" "storage_atividade_ansible" {
    name                        = "storageatvddvmansible"
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "atividade02 infra",
        tool = "ansible"
    }

    depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_linux_virtual_machine" "vm_atividade_ansible" {
    name                  = "myVMAnsible"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic_atividade_ansible.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsAnsibleDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvmansible"
    admin_username = var.user
    admin_password = var.password
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storage_atividade_ansible.primary_blob_endpoint
    }

    tags = {
        environment = "atividade02 infra",
        tool = "ansible"
    }

    depends_on = [  azurerm_resource_group.rg, 
                    azurerm_network_interface.nic_atividade_ansible, 
                    azurerm_network_interface.nic_atividade_db, 
                    azurerm_storage_account.storage_atividade_ansible, 
                    azurerm_public_ip.publicip_atividade_ansible,
                    azurerm_linux_virtual_machine.vm_mySQL ]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_linux_virtual_machine.vm_atividade_ansible]
  create_duration = "30s"
}

resource "null_resource" "upload" {
    provisioner "file" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = data.azurerm_public_ip.ip_atividade_ansible_data.ip_address
        }
        source = "ansible"
        destination = "/home/azureuser"
    }

    depends_on = [ time_sleep.wait_30_seconds ]
}

resource "null_resource" "deploy" {
    triggers = {
        order = null_resource.upload.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = var.user
            password = var.password
            host = data.azurerm_public_ip.ip_atividade_ansible_data.ip_address
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y software-properties-common",
            "sudo apt-add-repository --yes --update ppa:ansible/ansible",
            "sudo apt-get -y install python3 ansible",
            "ansible-playbook -i /home/azureuser/ansible/hosts /home/azureuser/ansible/main.yml"
        ]
    }
}