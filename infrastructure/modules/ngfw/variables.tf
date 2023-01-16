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
variable "transit-management-subnet" {
  description = "Transit Management Subnet"
}
variable "transit-public-subnet" {
  description = "Transit Public Subnet"
}
variable "transit-private-subnet" {
  description = "Transit Private Subnet"
}
variable "panorama-server1" {
  description = "Panorama Server 1 IP"
}
variable "auth-key" {
  description = "VM Auth Key from Panorama"
}
variable "template-stack" {
  description = "Panorama Template Stack for NGFW"
}
variable "device-group" {
  description = "Panorama Device Group for NGFW"
}
variable "admin-user" {
  description = "NGFW default admin username"
}
variable "admin-pass" {
  description = "NGFW default admin password"
}

# Ensure you keep them names vmseries0 and vmseries1 or you will have to change reference in the TF files.
variable "vmseries" {
  description = "Definition of the VM-Series deployments"
  default = {
    vmseries0 = {
      instance_size = "Standard_DS3_v2"
      # License options "byol", "bundle1", "bundle2"
      license           = "byol"
      version           = "10.2.3"
      availability_zone = 1
    }
    vmseries1 = {
      instance_size = "Standard_DS3_v2"
      # License options "byol", "bundle1", "bundle2"
      license           = "byol"
      version           = "10.2.3"
      availability_zone = 2
    }
  }
}

variable "inbound_tcp_ports" {
  default = [22, 80, 443]
}

variable "inbound_udp_ports" {
  default = [500, 4500]
}