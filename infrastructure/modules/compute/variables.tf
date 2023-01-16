variable "transit-prefix" {
  description = "Transit Resource Group Prefix"
  type        = string
}
variable "azure-region" {
  description = "Azure Region"
  type        = string
}
variable "default-tags" {
  description = "Default tags to apply to resources"
}
variable "admin-user" {
  description = "NGFW default admin username"
}
variable "admin-pass" {
  description = "NGFW default admin password"
}