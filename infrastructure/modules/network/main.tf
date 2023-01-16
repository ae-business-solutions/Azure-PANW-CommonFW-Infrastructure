#VNETs

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "transit-management-NSG" {
  name                = "transit-management-security-group"
  location            = data.azurerm_resource_group.transitRG.location
  resource_group_name = data.azurerm_resource_group.transitRG.name

  #Inbound Security Rules
  security_rule {
    name                       = "AllowPublicManagement"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "443"]
    source_address_prefixes    = var.management-external
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowManagement"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.management-internal
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1500
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.default-tags)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "transit-public-NSG" {
  name                = "transit-public-security-group"
  location            = data.azurerm_resource_group.transitRG.location
  resource_group_name = data.azurerm_resource_group.transitRG.name

  #Inbound Security Rules
  security_rule {
    name                       = "AllowInboundInternet"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 1040
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1500
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  #Outbound Security Rules
  security_rule {
    name                       = "AllowOutboundInternet"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
  security_rule {
    name                       = "AllowPublicToPublic"
    priority                   = 1010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.128.0.0/23"
    destination_address_prefix = "10.128.0.0/23"
  }
  security_rule {
    name                       = "DenyAllOutbound"
    priority                   = 1500
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.default-tags)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "transit-private-NSG" {
  name                = "transit-private-security-group"
  location            = data.azurerm_resource_group.transitRG.location
  resource_group_name = data.azurerm_resource_group.transitRG.name

  tags = merge(var.default-tags)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "transit" {
  name                = "transit-network"
  location            = data.azurerm_resource_group.transitRG.location
  resource_group_name = data.azurerm_resource_group.transitRG.name
  address_space       = var.transit-supernet

  tags = merge(var.default-tags)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "transit-management" {
  name                 = "transit-management"
  resource_group_name  = data.azurerm_resource_group.transitRG.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [var.transit-management-subnet]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "transit-management" {
  subnet_id                 = azurerm_subnet.transit-management.id
  network_security_group_id = azurerm_network_security_group.transit-management-NSG.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "transit-public" {
  name                 = "transit-public"
  resource_group_name  = data.azurerm_resource_group.transitRG.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [var.transit-public-subnet]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "transit-public" {
  subnet_id                 = azurerm_subnet.transit-public.id
  network_security_group_id = azurerm_network_security_group.transit-public-NSG.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "transit-private" {
  name                 = "transit-private"
  resource_group_name  = data.azurerm_resource_group.transitRG.name
  virtual_network_name = azurerm_virtual_network.transit.name
  address_prefixes     = [var.transit-private-subnet]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "transit-private" {
  subnet_id                 = azurerm_subnet.transit-private.id
  network_security_group_id = azurerm_network_security_group.transit-private-NSG.id
}

#VNET Peering

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "mgmt-to-transit-management" {
  name                      = "mgmt-to-transit-management"
  resource_group_name       = data.azurerm_resource_group.transitRG.name
  virtual_network_name      = azurerm_virtual_network.transit.name
  remote_virtual_network_id = data.azurerm_virtual_network.mgmt.id
}
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering
resource "azurerm_virtual_network_peering" "transit-management-to-mgmt" {
  name                      = "transit-management-to-mgmt"
  resource_group_name       = data.azurerm_resource_group.MGMTRG.name
  virtual_network_name      = data.azurerm_virtual_network.mgmt.name
  remote_virtual_network_id = azurerm_virtual_network.transit.id
}