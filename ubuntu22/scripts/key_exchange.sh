#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False
user=$(yq '.user' < /var/inert/settings.yaml)
ansible ssh -m shell -a "ssh-keygen -q -b 2048 -t rsa -N '' -C '$user' -f /home/$user/.ssh/id_rsa creates='/home/$user/.ssh/id_rsa'" -i /var/inert/inventory/sshpass.yaml -b -u $user
ansible ssh -m shell -a "chown -R $user:$user /home/$user/.ssh" -i /var/inert/inventory/sshpass.yaml -b -u $user

