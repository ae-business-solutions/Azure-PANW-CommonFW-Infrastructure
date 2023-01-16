
#Mgmt RG
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "MGMTRG" {
  name = var.mgmt-prefix
}

#Transit RG
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "transitRG" {
  name = var.transit-prefix
}

# Mgmt VNET
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_virtual_network" "mgmt" {
  name                = "mgmt-network"
  resource_group_name = data.azurerm_resource_group.MGMTRG.name
}