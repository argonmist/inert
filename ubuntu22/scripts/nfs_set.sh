#!/bin/bash

vars='/var/inert/ansible/group_vars/all.yml'
nfsIP=$(yq ".nfs.server.ip" < $vars)
user=$(yq '.user' < $vars)
echo "$nfsIP nfs" >> /etc/hosts

cat << EOF >> /root/.ssh/config
Host nfs
    USER $user
    StrictHostKeyChecking=no
    IdentityFile ~/.ssh/id_rsa
EOF
