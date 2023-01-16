# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group
data "azurerm_resource_group" "transitRG" {
  name = var.transit-prefix
}

# Transit VNET
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network
data "azurerm_virtual_network" "transit" {
  name                = "transit-network"
  resource_group_name = data.azurerm_resource_group.transitRG.name
}

# Management Subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "management" {
  name                 = "transit-management"
  resource_group_name  = data.azurerm_resource_group.transitRG.name
  virtual_network_name = data.azurerm_virtual_network.transit.name
}

# Public Subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "public" {
  name                 = "transit-public"
  resource_group_name  = data.azurerm_resource_group.transitRG.name
  virtual_network_name = data.azurerm_virtual_network.transit.name
}

# Private Subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet
data "azurerm_subnet" "private" {
  name                 = "transit-private"
  resource_group_name  = data.azurerm_resource_group.transitRG.name
  virtual_network_name = data.azurerm_virtual_network.transit.name
}