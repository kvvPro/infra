variable "vsphere_user" {
  description = "vsphere_user"
  type        = string
}

variable "vsphere_password" {
  description = "vsphere_password"
  type        = string
  sensitive = true
}

variable "vsphere_server" {
  description = "vsphere_server"
  type        = string
}

variable "allow_unverified_ssl" {
  description = "allow_unverified_ssl"
  type        = bool
}

variable "vsphere_datacenter" {
  description = "vsphere_datacenter"
  type        = string
}

variable "vsphere_datastore" {
  description = "vsphere_datastore"
  type        = string
}

variable "vsphere_host" {
  description = "vsphere_host"
  type        = string
}

variable "vsphere_network" {
  description = "vsphere_network"
  type        = string
}

variable "vm_template" {
  description = "vm_template"
  type        = string
}

variable "gateway" {
  description = "gateway"
  type        = string
}

variable "domain" {
  description = "domain"
  type        = string
}

// vsphere
## Global ##

# Required variables

variable "machines" {
  description = "Cluster machines"
  type = map(object({
    node_type = string
    ip        = string
    netmask   = string
  }))
}

variable "ssh_public_keys" {
  description = "List of public SSH keys which are injected into the VMs."
  type        = list(string)
}

# Optional variables (ones where reasonable defaults exist)
variable "vapp" {
  default = false
}

variable "interface_name" {
  default = "ens192"
}

variable "folder" {
  default = ""
}

variable "prefix" {
  default = "k8s"
}

variable "inventory_file" {
  default = "inventory.ini"
}

variable "dns_primary" {
  default = "8.8.4.4"
}

variable "dns_secondary" {
  default = "8.8.8.8"
}

variable "firmware" {
  default = "bios"
}

variable "hardware_version" {
  default = "20"
}

## Master ##

variable "master_cores" {
  default = 2
}

variable "master_memory" {
  default = 4096
}

variable "master_disk_size" {
  default = "25"
}

## Worker ##

variable "worker_cores" {
  default = 2
}

variable "worker_memory" {
  default = 8192
}
variable "worker_disk_size" {
  default = "50"
}

# ssh
variable "guest_ssh_user" {}
variable "guest_ssh_password" {}
variable "ssh_private_key_path" {}
variable "ssh_public_key_path" {}
variable "root_ssh_user" {}
variable "root_ssh_password" {}