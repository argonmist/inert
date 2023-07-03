#!/bin/bash

add_ip(){
cat << EOF >> /var/inert/inventory/k8s.yaml
$1
EOF
}
vars='/var/inert/ansible/group_vars/all.yml'
k8sc=$(yq e '.k8s | length' < $vars)
user=$(yq '.user' < $vars)
pass=$(yq '.pass' < $vars)

cat << EOF > /var/inert/inventory/k8s.yaml
[all:vars]
ansible_ssh_pass=$pass
ansible_sudo_pass=$pass
ansible_ssh_private_key_file=/root/.ssh/id_rsa
ansible_ssh_user=$user
ansible_become = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
host_key_checking=False
validate_certs=False

[k8s]
EOF

for i in $(seq 1 $k8sc); do
  j=$(($i-1))
  role=$(yq ".k8s[$j]" < $vars | cut -d ':' -f1)
  ip=$(yq ".k8s[$j]" < $vars | cut -d ' ' -f2)
  if [ "$role" == "master" ]; then
    add_ip $ip
  elif [ "$role" == "worker" ]; then
    add_ip $ip
  fi
done
