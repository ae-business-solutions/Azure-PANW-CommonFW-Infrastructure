terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
    local = {
      version = "~> 2.1"
    }
  }
  cloud {
    organization = "YourTCOrganizationName"

    workspaces {
      name = "Azure-Infrastructure"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  features {}
}

module "org" {
  source         = "./modules/org"
  azure-region   = var.azure-region
  transit-prefix = var.transit-prefix
  default-tags   = var.default-tags
}
module "network" {
  source                    = "./modules/network"
  azure-region              = var.azure-region
  transit-prefix            = var.transit-prefix
  mgmt-prefix               = var.mgmt-prefix
  default-tags              = var.default-tags
  transit-supernet          = var.transit-supernet
  transit-management-subnet = var.transit-management-subnet
  transit-public-subnet     = var.transit-public-subnet
  transit-private-subnet    = var.transit-private-subnet
  transit-vpn-subnet        = var.transit-vpn-subnet
  management-external       = var.management-external
  management-internal       = var.management-internal
  depends_on                = [module.org]
}

module "ngfw" {
  source                    = "./modules/ngfw"
  azure-region              = var.azure-region
  transit-prefix            = var.transit-prefix
  default-tags              = var.default-tags
  transit-management-subnet = var.transit-management-subnet
  transit-public-subnet     = var.transit-public-subnet
  transit-private-subnet    = var.transit-private-subnet
  panorama-server1          = var.panorama-server1
  auth-key                  = var.auth-key
  template-stack            = var.template-stack
  device-group              = var.device-group
  admin-user                = var.admin-user
  admin-pass                = var.admin-pass
  depends_on                = [module.network]
}

module "compute" {
  source         = "./modules/compute"
  azure-region   = var.azure-region
  transit-prefix = var.transit-prefix
  default-tags   = var.default-tags
  admin-user     = var.admin-user
  admin-pass     = var.admin-pass
  depends_on     = [module.network]
}