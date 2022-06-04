terraform {
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
      version = "0.11.8"
    }
  }
}

provider "volterra" {
  api_cert = var.f5xc_connection.cert
  api_key  = var.f5xc_connection.key
  url      = var.f5xc_connection.url
}

provider "vsphere" {
  user           = var.vsphere_connection.vsphere_username
  password       = var.vsphere_connection.vsphere_password
  vsphere_server = var.vsphere_connection.vsphere_server
  allow_unverified_ssl = true
}