# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "storage_account_name" {
  length  = 5
  lower   = true
  upper   = false
  special = false
  numeric = false
}

# Storage Account:  NGFW Bootstrap
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "bootstrap" {
  for_each                  = var.vmseries
  name                      = "bootstrap${each.key}${random_string.storage_account_name.result}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  location                  = var.azure-region
  resource_group_name       = data.azurerm_resource_group.transitRG.name
  enable_https_traffic_only = true

  depends_on = [data.azurerm_resource_group.transitRG]

  tags = merge(var.default-tags)
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
resource "azurerm_storage_share" "bootstrap" {
  for_each             = var.vmseries
  name                 = "vm-series"
  storage_account_name = azurerm_storage_account.bootstrap[each.key].name
  quota                = 50
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_directory
resource "azurerm_storage_share_directory" "config" {
  for_each             = var.vmseries
  name                 = "config"
  share_name           = azurerm_storage_share.bootstrap[each.key].name
  storage_account_name = azurerm_storage_account.bootstrap[each.key].name

  depends_on = [azurerm_storage_share.bootstrap]
}

# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "initcfg_txt" {
  template = file("${path.module}/init-cfg.txt.template")
  vars = {
    panorama-server1 = var.panorama-server1
    template-stack   = var.template-stack
    device-group     = var.device-group
    auth-key         = var.auth-key
  }
}

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "initcfg_txt" {
  filename = "${path.root}/init-cfg.txt"
  content  = data.template_file.initcfg_txt.rendered
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_file
resource "azurerm_storage_share_file" "initcfg" {
  for_each         = var.vmseries
  name             = "init-cfg.txt"
  path             = "config"
  storage_share_id = azurerm_storage_share.bootstrap[each.key].id
  source           = "${path.root}/init-cfg.txt"

  depends_on = [azurerm_storage_share_directory.config, azurerm_storage_share.bootstrap]
}