#!/bin/bash
cat << EOF > /var/inert/inventory/default.yaml
[all:vars]
ansible_ssh_pass=$2
ansible_sudo_pass=$2
ansible_ssh_private_key_file=/root/.ssh/id_rsa
ansible_ssh_user=$1
ansible_become = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
host_key_checking=False
validate_certs=False
EOF

