output "Appstack_Cluster_Name" {
   value = var.virtual_machine_vapp.clustername
}
output "Master_Nodes_Name" {
   value = vsphere_virtual_machine.master.*.name
}
output "Master_Nodes_IP" { 
   value = vsphere_virtual_machine.master.*.default_ip_address
}
output "Worker_Nodes_Name" {
   value = vsphere_virtual_machine.worker.*.name
}
output "Worker_Nodes_IP" {
   value = vsphere_virtual_machine.worker.*.default_ip_address
}
