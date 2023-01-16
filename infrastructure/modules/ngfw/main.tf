# Public IP Address:  Management
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "management" {
  for_each            = var.vmseries
  name                = "ngfw-nic-management-pip-${each.key}"
  location            = var.azure-region
  resource_group_name = data.azurerm_resource_group.transitRG.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.default-tags)
}

# Network Interface:  Management
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "ngfw-management" {
  for_each             = var.vmseries
  name                 = "ngfw-${each.key}-nic-management"
  location             = var.azure-region
  resource_group_name  = data.azurerm_resource_group.transitRG.name
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "ngfw-mgmt-ipconfig1-${each.key}"
    subnet_id                     = data.azurerm_subnet.management.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.management[each.key].id
  }

  depends_on = [azurerm_public_ip.management]

  tags = merge(var.default-tags)
}

# Network Security Group: Management
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "management" {
  name                = "ngfw-management-nsg"
  location            = var.azure-region
  resource_group_name = data.azurerm_resource_group.transitRG.name

  security_rule {
    name                       = "management-inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "22"]
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "management-outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.default-tags)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association
resource "azurerm_network_interface_security_group_association" "management" {
  for_each                  = var.vmseries
  network_interface_id      = azurerm_network_interface.ngfw-management[each.key].id
  network_security_group_id = azurerm_network_security_group.management.id

  depends_on = [azurerm_network_interface.ngfw-management]
}


# Public IP Address:  Public
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "public" {
  for_each            = var.vmseries
  name                = "ngfw-nic-public-pip-${each.key}"
  location            = var.azure-region
  resource_group_name = data.azurerm_resource_group.transitRG.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.default-tags)
}

# Network Interface:  Public
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "ngfw-public" {
  for_each                      = var.vmseries
  name                          = "ngfw-${each.key}-nic-public"
  location                      = var.azure-region
  resource_group_name           = data.azurerm_resource_group.transitRG.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ngfw-public-ipconfig1-${each.key}"
    subnet_id                     = data.azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public[each.key].id
  }

  depends_on = [azurerm_public_ip.public]

  tags = merge(var.default-tags)
}

# Network Security Group: Public
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "public" {
  name                = "ngfw-public-nsg"
  location            = var.azure-region
  resource_group_name = data.azurerm_resource_group.transitRG.name

  security_rule {
    name                       = "public-inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "public-outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.default-tags)
}

resource "azurerm_network_interface_security_group_association" "public" {
  for_each                  = var.vmseries
  network_interface_id      = azurerm_network_interface.ngfw-public[each.key].id
  network_security_group_id = azurerm_network_security_group.public.id

  depends_on = [azurerm_network_interface.ngfw-public]
}


# Network Interface:  Private
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "ngfw-private" {
  for_each                      = var.vmseries
  name                          = "ngfw-${each.key}-nic-private"
  location                      = var.azure-region
  resource_group_name           = data.azurerm_resource_group.transitRG.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ngfw-private-ipconfig1-${each.key}"
    subnet_id                     = data.azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(var.default-tags)
}

# Network Security Group: Private
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "private" {
  name                = "ngfw-private-nsg"
  location            = var.azure-region
  resource_group_name = data.azurerm_resource_group.transitRG.name

  security_rule {
    name                       = "private-inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "private-outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.default-tags)
}

resource "azurerm_network_interface_security_group_association" "private" {
  for_each                  = var.vmseries
  network_interface_id      = azurerm_network_interface.ngfw-private[each.key].id
  network_security_group_id = azurerm_network_security_group.private.id

  depends_on = [azurerm_network_interface.ngfw-private]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
resource "azurerm_linux_virtual_machine" "vmseries" {
  for_each = var.vmseries

  # Resource Group & Location:
  location            = var.azure-region
  resource_group_name = data.azurerm_resource_group.transitRG.name

  name = "${each.key}-vm"

  # Availabilty Zone:
  # Note that Availability Zones are NOT available in all regions:
  # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
  # Comment out the next line if you are deploying to a region that does not support AZs.
  zone = each.value.availability_zone

  # Instance
  size = each.value.instance_size

  # Username and Password Authentication:
  disable_password_authentication = false
  admin_username                  = var.admin-user
  admin_password                  = var.admin-pass

  # Network Interfaces:
  network_interface_ids = [
    azurerm_network_interface.ngfw-management[each.key].id,
    azurerm_network_interface.ngfw-public[each.key].id,
    azurerm_network_interface.ngfw-private[each.key].id,
  ]

  plan {
    name      = each.value.license
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = each.value.license
    version   = each.value.version
  }

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootstrap[each.key].primary_blob_endpoint
  }


  # Bootstrap Information for Azure:
  custom_data = base64encode(join(
    ",",
    [
      "storage-account=${azurerm_storage_account.bootstrap[each.key].name}",
      "access-key=${azurerm_storage_account.bootstrap[each.key].primary_access_key}",
      "file-share=${azurerm_storage_share.bootstrap[each.key].name}",
      "share-directory=",
    ],
  ))

  # Dependencies:
  depends_on = [
    azurerm_network_interface.ngfw-private,
    azurerm_network_interface.ngfw-public,
    azurerm_network_interface.ngfw-management,
  ]

  tags = merge(var.default-tags)
}
