#cloud-config
users:
  - default
  - name: ${guest_ssh_user}
    passwd: '${guest_ssh_password}'
    lock_passwd: false
    groups: sudo, users, admin
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
    %{ for ssh_public_key in ssh_public_keys ~}
      - ${ssh_public_key}
    %{ endfor ~}
