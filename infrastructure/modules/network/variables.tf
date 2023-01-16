variable "transit-prefix" {
  description = "Transit Resource Group Prefix"
  type        = string
}
variable "mgmt-prefix" {
  description = "Mgmt Resource Group Prefix"
  type        = string
}
variable "azure-region" {
  description = "Azure Region"
  type        = string
}
variable "default-tags" {
  description = "Default tags to apply to resources"
}
variable "transit-supernet" {
  description = "Transit Supernet"
}
variable "transit-management-subnet" {
  description = "Transit Management Subnet"
}
variable "transit-public-subnet" {
  description = "Transit Public Subnet"
}
variable "transit-private-subnet" {
  description = "Transit Private Subnet"
}
variable "transit-vpn-subnet" {
  description = "Transit VPN Subnet"
}
variable "management-external" {
  description = "External Management IP ranges"
}
variable "management-internal" {
  description = "Internal Management IP ranges"
}