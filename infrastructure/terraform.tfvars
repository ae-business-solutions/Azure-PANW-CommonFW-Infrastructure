azure-region              = "westus2"
transit-prefix            = "transit-group"
mgmt-prefix               = "mgmt-group"
default-tags              = { environment = "prod", division = "IT" }
transit-supernet          = ["10.110.0.0/16"]
transit-management-subnet = "10.110.255.0/24"
transit-public-subnet     = "10.110.129.0/24"
transit-private-subnet    = "10.110.0.0/24"
transit-vpn-subnet        = "10.110.40.0/24"
panorama-server1          = "10.255.0.10"
management-external       = ["168.63.129.16/32"] # Note that 168.63.129.16/32 should always be included as that is the range that Azure health checks originate from.
management-internal       = ["10.110.0.0/16", "10.255.0.0/16", "10.222.0.0/16"]
template-stack            = "Azure-Template-stack"
device-group              = "Azure-NGFW"