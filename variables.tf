variable "f5xc_connection" {
  type = map(string)
  description = "Configuration details for connecting to F5 XC"
  default = {
    cert = "/MacVSCodeProjects/f5xc/terraform/volterra.crt"
    key = "/MacVSCodeProjects/f5xc/terraform/volterra.key"
    # Your F5 XC Tenant URI
    url = "https://partners-taiwan.console.ves.volterra.io/api"
  }
}

variable "vsphere_connection" {
  type = map(string)
  description = "Configuration details for connecting to vCenter"
  default = {
    vsphere_username = "administrator@vsphere.local"
    vsphere_password = "Password123"
    vsphere_server = "vcenter.f5xx.com"
  }
}

variable "virtual_machine_template" {
  type = map(string)
  description = "Configuration details for VM template"
  default = {
    # Master nodes must be 1 or 3
    master_count = 3
    # Worker nodes can be present only if master nodes have 3
    worker_count = 5
    master_name_prefix = "master-"
    worker_name_prefix = "worker-"
    datacenter = "DC"
    cluster = "Cluster"
    resource_pool = "F5XC"
    template = "f5xc-vmware-7.2009.10-202107041731"
    num_cpus = 4
    memory = 16384
    datastore = "vSAN"
    # Name of port group
    network = "DPG"
  }
}

variable "virtual_machine_vapp" {
  type = map(string)
  description = "Configuration details for F5 XC customer site"
  default = {
    regurl = "ves.volterra.io"
    certifiedhardware = "vmware-voltstack-combo"
    # F5 XC site token
    token = "123456789abc"
    latitude = "25"
    longitude = "121"
    clustername = "cluster-0"
    interface_name = "eth0"
    interface_dhcp = "no"
    interface_role = "public"
    # The network subnet that assigned to master and worker nodes
    interface_subnet = "10.0.0.0/24"
    # Master node starting IP address, just input 4th octet of the IP address
    master_hostnum = "1"
    # Worker node starting IP address, just input 4th octet of the IP address
    worker_hostnum = "4"  
    route = "0.0.0.0/0"
    gateway = "10.0.0.254"
    dns0 = "10.10.10.53"
    dns1 = "10.20.20.53"
  }
}