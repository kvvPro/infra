data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

module "kubernetes" {
  source = "./modules/kubernetes-cluster"

  prefix = var.prefix
  domain = var.domain

  machines = var.machines

  ## Master ##
  master_cores     = var.master_cores
  master_memory    = var.master_memory
  master_disk_size = var.master_disk_size

  ## Worker ##
  worker_cores     = var.worker_cores
  worker_memory    = var.worker_memory
  worker_disk_size = var.worker_disk_size

  ## Global ##

  gateway       = var.gateway
  dns_primary   = var.dns_primary
  dns_secondary = var.dns_secondary

  pool_id      = data.vsphere_host.host.resource_pool_id
  datastore_id = data.vsphere_datastore.datastore.id

  folder                = var.folder
  guest_id              = data.vsphere_virtual_machine.template.guest_id
  scsi_type             = data.vsphere_virtual_machine.template.scsi_type
  network_id            = data.vsphere_network.network.id
  adapter_type          = data.vsphere_virtual_machine.template.network_interface_types[0]
  interface_name        = var.interface_name
  firmware              = var.firmware
  hardware_version      = var.hardware_version
  disk_thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  template_id = data.vsphere_virtual_machine.template.id
  vapp        = var.vapp

  ssh_public_keys = var.ssh_public_keys
  guest_ssh_user = var.guest_ssh_user
  guest_ssh_password = var.guest_ssh_password
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path = var.ssh_public_key_path
  root_ssh_user = var.root_ssh_user
  root_ssh_password = var.root_ssh_password
}

#
# Generate ansible inventory
#

resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    connection_strings_master = join("\n", formatlist("%s ansible_user=ubuntu ansible_host=%s etcd_member_name=etcd%d",
      keys(module.kubernetes.master_ip),
      values(module.kubernetes.master_ip),
    range(1, length(module.kubernetes.master_ip) + 1))),
    connection_strings_worker = join("\n", formatlist("%s ansible_user=ubuntu ansible_host=%s",
      keys(module.kubernetes.worker_ip),
    values(module.kubernetes.worker_ip))),
    list_master = join("\n", formatlist("%s", keys(module.kubernetes.master_ip))),
    list_worker = join("\n", formatlist("%s", keys(module.kubernetes.worker_ip)))
  })
  filename = var.inventory_file
}

# resource "vsphere_virtual_machine" "vm" {
#   name             = "tf-test"
#   datastore_id     = data.vsphere_datastore.datastore.id
#   resource_pool_id = data.vsphere_host.host.resource_pool_id
#   num_cpus         = 2
#   memory           = 8192
#   firmware         = "efi"
  
#   guest_id         = data.vsphere_virtual_machine.template.guest_id
#   scsi_type        = data.vsphere_virtual_machine.template.scsi_type
#   network_interface {
#     network_id   = data.vsphere_network.network.id
#     adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
#   }

#   disk {
#     label            = "disk0"
#     size             = data.vsphere_virtual_machine.template.disks.0.size
#     thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
#   }

#   clone {
#     template_uuid = data.vsphere_virtual_machine.template.id
#     linked_clone = true

#     customize {
#       linux_options {
#         host_name = "tf-test"
#         domain    = var.domain
#       }

#       network_interface {
#         ipv4_address = var.ipv4
#         ipv4_netmask = 24
#       }

#       ipv4_gateway = var.gateway
#     }
#   }
# }