#!/bin/bash
# 1 python for Ansible
sudo apt-get update
sudo apt-get -qq install python3 -y
sudo apt install -y acl
sudo apt install -y sshpass
# 2 preparation for cloud-init
sudo rm -r -f -d /var/lib/cloud/*
sudo setfacl -m g:adm:rw /etc/cloud/cloud.cfg
sudo echo "disable_vmware_customization: false" >> /etc/cloud/cloud.cfg
sudo sed -i "s/network: {config: disabled}/#network: {config: disabled}/" /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
sudo cloud-init clean --seed