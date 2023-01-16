# Network Interface: Private
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "compute-transit-nic" {
  name                 = "compute-transit-nic"
  location             = var.azure-region
  resource_group_name  = data.azurerm_resource_group.transitRG.name
  enable_ip_forwarding = false

  ip_configuration {
    name                          = "compute-transit-ipconfig1"
    subnet_id                     = data.azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(var.default-tags)
}

# Network Security Group: Private
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "compute-transit-nsg" {
  name                = "compute-transit-nsg"
  location            = var.azure-region
  resource_group_name = data.azurerm_resource_group.transitRG.name

  security_rule {
    name                       = "compute-inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["443", "22"]
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
  tags = merge(var.default-tags)
}

resource "azurerm_network_interface_security_group_association" "compute-transit-nsg" {
  network_interface_id      = azurerm_network_interface.compute-transit-nic.id
  network_security_group_id = azurerm_network_security_group.compute-transit-nsg.id
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "storage_account_name" {
  length  = 5
  lower   = true
  upper   = false
  special = false
  numeric = false
}

# Storage Account:  Compute Bootstrap
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "bootstrap" {
  name                      = "bootstrap${random_string.storage_account_name.result}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  location                  = var.azure-region
  resource_group_name       = data.azurerm_resource_group.transitRG.name
  enable_https_traffic_only = true

  depends_on = [data.azurerm_resource_group.transitRG]
  tags       = merge(var.default-tags)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
resource "azurerm_linux_virtual_machine" "compute-transit" {
  name = "compute-transit"
  # Resource Group & Location:
  location            = var.azure-region
  resource_group_name = data.azurerm_resource_group.transitRG.name

  # Network Interfaces:
  network_interface_ids = [azurerm_network_interface.compute-transit-nic.id]

  zone = "1"

  size = "Standard_DS3_v2"

  source_image_reference {
    publisher = "erockyenterprisesoftwarefoundationinc1653071250513"
    offer     = "rockylinux"
    sku       = "free"
    version   = "8.6.0"
  }

  plan {
    publisher = "erockyenterprisesoftwarefoundationinc1653071250513"
    name      = "free"
    product   = "rockylinux"
  }

  os_disk {
    name                 = "transit-compute-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootstrap.primary_blob_endpoint
  }


  # Username and Password Authentication:
  admin_username                  = var.admin-user
  admin_password                  = var.admin-pass
  disable_password_authentication = false

  # Dependencies:
  depends_on = [
    azurerm_network_interface.compute-transit-nic,
  ]
}