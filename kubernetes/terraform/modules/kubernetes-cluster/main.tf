resource "vsphere_virtual_machine" "worker" {
  for_each = {
    for name, machine in var.machines :
    name => machine
    if machine.node_type == "worker"
  }

  name = "${var.prefix}-${each.key}"

  resource_pool_id    = var.pool_id
  datastore_id        = var.datastore_id

  num_cpus            = var.worker_cores
  memory              = var.worker_memory
  memory_reservation  = var.worker_memory
  guest_id            = var.guest_id
  enable_disk_uuid    = "true" # needed for CSI provider
  scsi_type           = var.scsi_type
  folder              = var.folder
  firmware            = var.firmware
  # hardware_version    = var.hardware_version

  wait_for_guest_net_routable = false
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id        = var.network_id
    adapter_type      = var.adapter_type
  }

  disk {
    label             = "disk0"
    size              = var.worker_disk_size
    thin_provisioned  = var.disk_thin_provisioned
  }

  lifecycle {
    ignore_changes    = [disk]
  }

  clone {
    template_uuid     = var.template_id
    # linked_clone      = true
    customize {
      linux_options {
        host_name = "${var.prefix}-${each.key}"
        domain    = var.domain
      }
      network_interface {
        ipv4_address = each.value.ip
        ipv4_netmask = each.value.netmask
      }

      ipv4_gateway = var.gateway
    }
  }

  cdrom {
    client_device = true
  }

  dynamic "vapp" {
    for_each = var.vapp ? [1] : []

    content {
      properties = {
        "user-data" = base64encode(templatefile("${path.module}/templates/vapp-cloud-init.tpl", { ssh_public_keys = var.ssh_public_keys }))
      }
    }
  }

  # # First delete all files from /var/lib/cloud/ to ensure clear init of cloud-init
  # provisioner "local-exec" {
  #   command = "rm -r -f -d /var/lib/cloud/* && sed -i \"$ a\\\\\ndisable_vmware_customization: false\" /etc/cloud/cloud.cfg && sed -i \"s/network: {config: disabled}/#network: {config: disabled}/\" /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg && cloud-init clean --seed"
  #   # connection {
  #   #   type = "ssh"
  #   #   user = var.root_ssh_user
  #   #   password = var.root_ssh_password
  #   #   host     = each.value.ip
  #   # }
  # }

  # Ansible requires Python to be installed on the remote machines (as well as the local machine).
  # and install sshpass
  provisioner "remote-exec" {
    inline = ["sudo apt-get update && sudo apt-get -qq install python3 -y && sudo apt install -y sshpass"]

    connection {
      type     = "ssh"
      user     = var.root_ssh_user
      password = var.root_ssh_password
      host     = each.value.ip
      # private_key = file(var.ssh_private_key_path)
    }
  }

  extra_config = {
    "isolation.tools.copy.disable"         = "FALSE"
    "isolation.tools.paste.disable"        = "FALSE"
    "isolation.tools.setGUIOptions.enable" = "TRUE"
    "guestinfo.userdata"                   = base64encode(templatefile("${path.module}/templates/cloud-init.tpl", { guest_ssh_user = var.guest_ssh_user,
      guest_ssh_password = var.guest_ssh_password,
      ssh_public_keys = var.ssh_public_keys }))
    "guestinfo.userdata.encoding"          = "base64"
    "guestinfo.metadata" = base64encode(templatefile("${path.module}/templates/metadata.tpl", { hostname = "${var.prefix}-${each.key}",
      interface_name = var.interface_name
      ip             = each.value.ip,
      netmask        = each.value.netmask,
      gw             = var.gateway,
      dns            = var.dns_primary,
    ssh_public_keys = var.ssh_public_keys }))
    "guestinfo.metadata.encoding" = "base64"
  }
}

resource "vsphere_virtual_machine" "master" {
  for_each = {
    for name, machine in var.machines :
    name => machine
    if machine.node_type == "master"
  }

  name = "${var.prefix}-${each.key}"

  resource_pool_id    = var.pool_id
  datastore_id        = var.datastore_id

  num_cpus            = var.master_cores
  memory              = var.master_memory
  memory_reservation  = var.master_memory
  guest_id            = var.guest_id
  enable_disk_uuid    = "true" # needed for CSI provider
  scsi_type           = var.scsi_type
  folder              = var.folder
  firmware            = var.firmware
  # hardware_version    = var.hardware_version

  wait_for_guest_net_routable = false
  wait_for_guest_net_timeout = 0

  network_interface {
    network_id        = var.network_id
    adapter_type      = var.adapter_type
  }

  disk {
    label             = "disk0"
    size              = var.master_disk_size
    thin_provisioned  = var.disk_thin_provisioned
  }

  lifecycle {
    ignore_changes    = [disk]
  }

  clone {
    template_uuid     = var.template_id
    # linked_clone      = true
    customize {
      linux_options {
        host_name = "${var.prefix}-${each.key}"
        domain    = var.domain
      }

      network_interface {
        ipv4_address = each.value.ip
        ipv4_netmask = each.value.netmask
      }

      ipv4_gateway = var.gateway
    }
  }

  cdrom {
    client_device = true
  }

  dynamic "vapp" {
    for_each = var.vapp ? [1] : []

    content {
      properties = {
        "user-data" = base64encode(templatefile("${path.module}/templates/vapp-cloud-init.tpl", { ssh_public_keys = var.ssh_public_keys }))
      }
    }
  }

  # First delete all files from /var/lib/cloud/ to ensure clear init of cloud-init
  provisioner "local-exec" {
    command = "rm -r -f -d /var/lib/cloud/*"
  }

  provisioner "local-exec" {
    command = "echo \"\ndisable_vmware_customization: false\" >> /etc/cloud/cloud.cfg"
  }

  provisioner "local-exec" {
    command = "sed -i \"s/network: {config: disabled}/#network: {config: disabled}/\" /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg"
  }

  provisioner "local-exec" {
    command = "cloud-init clean --seed"
  }

  # Ansible requires Python to be installed on the remote machines (as well as the local machine).
  # and install sshpass
  provisioner "remote-exec" {
    inline = ["sudo apt-get update && sudo apt-get -qq install python3 -y && sudo apt install -y sshpass"]

    connection {
      type     = "ssh"
      user     = var.root_ssh_user
      password = var.root_ssh_password
      host     = each.value.ip
      # private_key = file(var.ssh_private_key_path)
    }
  }

  extra_config = {
    "isolation.tools.copy.disable"         = "FALSE"
    "isolation.tools.paste.disable"        = "FALSE"
    "isolation.tools.setGUIOptions.enable" = "TRUE"
    "guestinfo.userdata"                   = base64encode(templatefile("${path.module}/templates/cloud-init.tpl", { guest_ssh_user = var.guest_ssh_user,
      guest_ssh_password = var.guest_ssh_password,
      ssh_public_keys = var.ssh_public_keys }))
    "guestinfo.userdata.encoding"          = "base64"
    "guestinfo.metadata" = base64encode(templatefile("${path.module}/templates/metadata.tpl", { hostname = "${var.prefix}-${each.key}",
      interface_name = var.interface_name
      ip             = each.value.ip,
      netmask        = each.value.netmask,
      gw             = var.gateway,
      dns            = var.dns_primary,
    ssh_public_keys = var.ssh_public_keys }))
    "guestinfo.metadata.encoding" = "base64"
  }
}
