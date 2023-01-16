output "azure-region" {
  description = "Azure Region"
  value       = var.azure-region
}
output "transit-prefix" {
  description = "Transit Resource Group prefix"
  value       = var.transit-prefix
}
output "mgmt-prefix" {
  description = "Mgmt Resource Group prefix"
  value       = var.mgmt-prefix
}
output "default-tags" {
  description = "Default tags to apply to resources"
  value       = var.default-tags
}
output "transit-supernet" {
  description = "Transit Supernet"
  value       = var.transit-supernet
}
output "transit-management-subnet" {
  description = "Transit Management Subnet"
  value       = var.transit-management-subnet
}
output "transit-public-subnet" {
  description = "Transit Public Subnet"
  value       = var.transit-public-subnet
}
output "transit-private-subnet" {
  description = "Transit Private Subnet"
  value       = var.transit-private-subnet
}
output "transit-vpn-subnet" {
  description = "Transit VPN Subnet"
  value       = var.transit-vpn-subnet
}
output "management-external" {
  description = "External Management IP ranges"
  value       = var.management-external
}
output "management-internal" {
  description = "Internal Management IP ranges"
  value       = var.management-internal
}
output "panorama-server1" {
  description = "Panorama Server 1 IP"
  value       = var.panorama-server1
}
output "template-stack" {
  description = "Panorama Template Stack for NGFW"
  value       = var.template-stack
}
output "device-group" {
  description = "Panorama Device Group for NGFW"
  value       = var.device-group
}
output "admin-user" {
  description = "NGFW default admin username"
  value       = var.admin-user
}