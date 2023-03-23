#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False
vars='/var/inert/ansible/group_vars/all.yml'
user=$(yq '.user' < $vars)
ansible ssh -m shell -a "ssh-keygen -q -b 2048 -t rsa -N '' -C '$user' -f /home/$user/.ssh/id_rsa creates='/home/$user/.ssh/id_rsa'" -i /var/inert/inventory/sshpass.yaml -b -u $user
ansible ssh -m shell -a "chown -R $user:$user /home/$user/.ssh" -i /var/inert/inventory/sshpass.yaml -b -u $user

deployIP=$(yq '.deploy' < $vars )
user=$(yq '.user' < $vars )
pass="$(yq '.pass' < $vars)"
if [ "$deployIP" != "null" ]; then
  echo $deployIP deploy >> /etc/hosts
fi

gocdIP=$(yq '.gocd' < $vars )
if [ "$gocdIP" != "null" ]; then
  echo $gocdIP gocd >> /etc/hosts
  sshpass -p $pass ssh-copy-id $user@$gocdIP

cat << EOF >> /root/.ssh/config
Host gocd
    USER $user
    StrictHostKeyChecking=no
    IdentityFile ~/.ssh/id_rsa
EOF
fi

k8s=$(yq ".k8s" < $vars)
if [ "$k8s" != "null" ]; then
  k8sc=$(yq e '.k8s | length' < $vars)
  mc=0
  wc=0
  for i in $(seq 1 $k8sc); do
    j=$(($i-1))
    hostname=$(yq ".k8s[$j]" < $vars | cut -d ':' -f1)
    if [ "$hostname" == "master" ]; then
      mc=$(($mc+1))
      ip=$(yq ".k8s[$j]" < $vars | cut -d ' ' -f2)
      echo $ip k8s-m$mc >> /etc/hosts
      sshpass -p $pass ssh-copy-id $user@$ip
    elif [ "$hostname" == "worker" ]; then
      wc=$(($wc+1))
      ip=$(yq ".k8s[$j]" < $vars | cut -d ' ' -f2)
      echo $ip k8s-w$wc >> /etc/hosts
      sshpass -p $pass ssh-copy-id $user@$ip
    fi
  done
cat << EOF >> /root/.ssh/config
Host k8s-m*
    USER $user
    StrictHostKeyChecking=no
    IdentityFile ~/.ssh/id_rsa
Host k8s-w*
    USER $user
    StrictHostKeyChecking=no
    IdentityFile ~/.ssh/id_rsa
EOF
fi

haproxy=$(yq ".haproxy" < $vars)
if [ "$haproxy" != "null" ]; then
  hac=$(yq e '.haproxy | length' < $vars)
  for i in $(seq 1 $hac); do
    j=$(($i-1))
    hostname=$(yq ".haproxy[$j]" < $vars | cut -d ':' -f1)
    if [ "$hostname" == "haproxy" ]; then
      ip=$(yq ".haproxy[$j]" < $vars | cut -d ' ' -f2)
      echo $ip ha$i >> /etc/hosts
      sshpass -p $pass ssh-copy-id $user@$ip
    elif [ "$hostname" == "vip" ]; then
      ip=$(yq ".haproxy[$j]" < $vars | cut -d ' ' -f2)
      echo $ip vip >> /etc/hosts
    fi
  done
cat << EOF >> /root/.ssh/config
Host ha*
    USER $user
    StrictHostKeyChecking=no
    IdentityFile ~/.ssh/id_rsa
EOF
fi


drbd=$(yq ".drbd" < $vars)
if [ "$drbd" != "null" ]; then
  ip=$(yq ".drbd.primary.ip" < $vars)
  echo $ip drbd-1 >> /etc/hosts
  sshpass -p $pass ssh-copy-id $user@$ip
  drbdc=$(yq e '.drbd.secondary.ip | length' < $vars)
  for i in $(seq 1 $drbdc); do
    j=$(($i-1))
    k=$(($i+1))
    ip=$(yq ".drbd.secondary.ip[$j]" < $vars)
    echo $ip drbd-$k >> /etc/hosts
    sshpass -p $pass ssh-copy-id $user@$ip
  done
cat << EOF >> /root/.ssh/config
Host drbd-*
    USER $user
    StrictHostKeyChecking=no
    IdentityFile ~/.ssh/id_rsa
EOF
fi
