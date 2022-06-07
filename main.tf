resource "vsphere_virtual_machine" "master" {
  count            = var.virtual_machine_template.master_count
  name             = "${format("${var.virtual_machine_template.master_name_prefix}%d", count.index)}"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.virtual_machine_template.num_cpus
  memory           = var.virtual_machine_template.memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label          = "disk0"
    size           = data.vsphere_virtual_machine.template.disks.0.size
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
  vapp {
    properties = {
      "guestinfo.ves.regurl" = "ves.volterra.io"
      "guestinfo.ves.certifiedhardware" = var.virtual_machine_vapp.certifiedhardware
      "guestinfo.ves.token" = var.virtual_machine_vapp.token
      "guestinfo.ves.latitude" = var.virtual_machine_vapp.latitude
      "guestinfo.ves.longitude" = var.virtual_machine_vapp.longitude
      "guestinfo.ves.clustername" = var.virtual_machine_vapp.clustername
      "guestinfo.hostname" = "${format("${var.virtual_machine_template.master_name_prefix}%d", count.index)}"
      "guestinfo.interface.0.name" = "eth0"
      "guestinfo.interface.0.dhcp" = var.virtual_machine_vapp.interface_dhcp
      "guestinfo.interface.0.role" = "public"
      "guestinfo.interface.0.ip.0.address" = "${cidrhost(var.virtual_machine_vapp.interface_subnet, var.virtual_machine_vapp.master_hostnum+count.index)}/${element(split("/", var.virtual_machine_vapp.interface_subnet), 1)}"
      "guestinfo.interface.0.route.0.destination" = var.virtual_machine_vapp.route
      "guestinfo.interface.0.route.0.gateway" = var.virtual_machine_vapp.gateway
      "guestinfo.dns.server.0" = var.virtual_machine_vapp.dns0
      "guestinfo.dns.server.1" = var.virtual_machine_vapp.dns1 
    }
  }
  lifecycle {
    ignore_changes = [
      vapp[0].properties["guestinfo.ves.regurl"],
      vapp[0].properties["guestinfo.hostname"],
      vapp[0].properties["guestinfo.interface.0.name"],
      vapp[0].properties["guestinfo.interface.0.role"]
    ]
  }
}

resource "vsphere_virtual_machine" "worker" {
  count            = var.virtual_machine_template.worker_count
  name             = "${format("${var.virtual_machine_template.worker_name_prefix}%d", count.index)}"
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.virtual_machine_template.num_cpus
  memory           = var.virtual_machine_template.memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label          = "disk0"
    size           = data.vsphere_virtual_machine.template.disks.0.size
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
  vapp {
    properties = {
      "guestinfo.ves.regurl" = "ves.volterra.io"
      "guestinfo.ves.certifiedhardware" = var.virtual_machine_vapp.certifiedhardware
      "guestinfo.ves.token" = var.virtual_machine_vapp.token
      "guestinfo.ves.latitude" = var.virtual_machine_vapp.latitude
      "guestinfo.ves.longitude" = var.virtual_machine_vapp.longitude
      "guestinfo.ves.clustername" = var.virtual_machine_vapp.clustername
      "guestinfo.hostname" = "${format("${var.virtual_machine_template.worker_name_prefix}%d", count.index)}"
      "guestinfo.interface.0.name" = "eth0"
      "guestinfo.interface.0.dhcp" = var.virtual_machine_vapp.interface_dhcp
      "guestinfo.interface.0.role" = "public"
      "guestinfo.interface.0.ip.0.address" = "${cidrhost(var.virtual_machine_vapp.interface_subnet, var.virtual_machine_vapp.worker_hostnum+count.index)}/${element(split("/", var.virtual_machine_vapp.interface_subnet), 1)}"
      "guestinfo.interface.0.route.0.destination" = var.virtual_machine_vapp.route
      "guestinfo.interface.0.route.0.gateway" = var.virtual_machine_vapp.gateway
      "guestinfo.dns.server.0" = var.virtual_machine_vapp.dns0
      "guestinfo.dns.server.1" = var.virtual_machine_vapp.dns1
    }
  }
  lifecycle {
    ignore_changes = [
      vapp[0].properties["guestinfo.ves.regurl"],
      vapp[0].properties["guestinfo.interface.0.name"],
      vapp[0].properties["guestinfo.interface.0.role"]
    ]
  }
}

resource "volterra_voltstack_site" "cluster" {
  name      = var.virtual_machine_vapp.clustername
  namespace = "system"
  volterra_certified_hw = var.virtual_machine_vapp.certifiedhardware
  master_nodes = vsphere_virtual_machine.master.*.name
  worker_nodes = vsphere_virtual_machine.worker.*.name
  custom_network_config {
    default_config = true
    default_interface_config = true
    no_network_policy = true
    no_forward_proxy = true
    no_global_network = true
    vip_vrrp_mode = "VIP_VRRP_ENABLE"
  }
  coordinates {
    latitude = var.virtual_machine_vapp.latitude
    longitude = var.virtual_machine_vapp.longitude
  }
  depends_on = [vsphere_virtual_machine.master, vsphere_virtual_machine.worker]
}

resource "time_sleep" "five_minutes" {
  create_duration = "5m"
  depends_on = [volterra_voltstack_site.cluster]
}

resource "volterra_registration_approval" "master" {
  count = var.virtual_machine_template.master_count
  hostname = "${format("${var.virtual_machine_template.master_name_prefix}%d", count.index)}"
  cluster_name  = var.virtual_machine_vapp.clustername
  cluster_size  = var.virtual_machine_template.master_count
  retry = 10
  wait_time = 60
  latitude = var.virtual_machine_vapp.latitude
  longitude = var.virtual_machine_vapp.longitude
  depends_on = [time_sleep.five_minutes]
}

resource "volterra_registration_approval" "worker" {
  count = var.virtual_machine_template.worker_count
  hostname = "${format("${var.virtual_machine_template.worker_name_prefix}%d", count.index)}"
  cluster_name  = var.virtual_machine_vapp.clustername
  cluster_size  = var.virtual_machine_template.master_count
  retry = 10
  wait_time = 60
  latitude = var.virtual_machine_vapp.latitude
  longitude = var.virtual_machine_vapp.longitude
  depends_on = [volterra_registration_approval.master]
}