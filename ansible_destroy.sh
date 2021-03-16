terraform destroy --auto-approve    --target azurerm_linux_virtual_machine.vm_atividade_ansible \
                                    --target azurerm_storage_account.storage_atividade_ansible \
                                    --target azurerm_network_interface.nic_atividade_ansible \
                                    --target azurerm_public_ip.publicip_atividade_ansible
