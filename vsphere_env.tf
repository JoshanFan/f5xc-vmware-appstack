data "vsphere_datacenter" "datacenter" {
  name = var.virtual_machine_template.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.virtual_machine_template.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_resource_pool" "resource_pool" {
  name                    = var.virtual_machine_template.resource_pool
  parent_resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
}

data "vsphere_resource_pool" "resource_pool" {
  name          = var.virtual_machine_template.resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
  depends_on    = [vsphere_resource_pool.resource_pool]
}

data "vsphere_virtual_machine" "template" {
  name          = var.virtual_machine_template.template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.virtual_machine_template.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.virtual_machine_template.network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "f5xc_master_vm_rule" {
  name                = "f5xc_master_vm_rule"
  compute_cluster_id  = data.vsphere_compute_cluster.cluster.id
  virtual_machine_ids = vsphere_virtual_machine.master.*.id
}