#!/bin/bash

cat << EOF > /var/inert/conf/cluster.yaml
nodes:
EOF

vars='/var/inert/ansible/group_vars/all.yml'
k8sc=$(yq e '.k8s | length' < $vars)
user=$(yq '.user' < $vars)
echo $k8sc
for i in $(seq 1 $k8sc); do
  j=$(($i-1))
  role=$(yq ".k8s[$j]" < $vars | cut -d ':' -f1)
  ip=$(yq ".k8s[$j]" < $vars | cut -d ' ' -f2)
  if [ "$role" == "master" ]; then
cat << EOF >> /var/inert/conf/cluster.yaml
- address: $ip
  role:
    - controlplane
    - etcd
  user: $user
  docker_socket: /var/run/docker.sock
  ssh_key_path: /root/.ssh/id_rsa
EOF
  elif [ "$role" == "worker" ]; then
cat << EOF >> /var/inert/conf/cluster.yaml
- address: $ip
  role:
    - worker
  user: $user
  docker_socket: /var/run/docker.sock
  ssh_key_path: /root/.ssh/id_rsa
EOF
  fi
done

cat << EOF >> /var/inert/conf/cluster.yaml
addon_job_timeout: 600

enable_cri_dockerd: true

cluster_name: pgtalk-k8s

kubernetes_version: v1.24.9-rancher1-1

authentication:
  strategy: x509
  sans:
  - "api.my-k8s-master.com"

ingress:
  provider: none

network:
  plugin: calico

services:
  etcd:
    snapshot: true
    creation: 6h
    retention: 24h
  kubelet:
    extra_args:
      runtime-request-timeout: 60m
EOF
