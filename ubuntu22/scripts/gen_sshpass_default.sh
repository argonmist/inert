#!/bin/bash
cat << EOF > /var/inert/inventory/sshpass.yaml
[all:vars]
ansible_ssh_pass=$2
ansible_sudo_pass=$2
ansible_become = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
host_key_checking=False
validate_certs=False
EOF
#export ANSIBLE_HOST_KEY_CHECKING=False
#ansible ssh -m shell -a "ssh-keygen -q -b 2048 -t rsa -N '' -C '$1' -f /home/$1/.ssh/id_rsa creates='/home/$1/.ssh/id_rsa'" -i /var/inert/inventory/sshpass.yaml -b -u $1
#ansible ssh -m shell -a "chown -R $1:$1 /home/$1/.ssh" -i /var/inert/inventory/sshpass.yaml -b -u $1

