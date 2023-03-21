#!/bin/bash
export ANSIBLE_HOST_KEY_CHECKING=False
user=$(yq '.user' < /var/inert/settings.yaml)
ansible ssh -m shell -a "ssh-keygen -q -b 2048 -t rsa -N '' -C '$user' -f /home/$user/.ssh/id_rsa creates='/home/$user/.ssh/id_rsa'" -i /var/inert/inventory/sshpass.yaml -b -u $user
ansible ssh -m shell -a "chown -R $user:$user /home/$user/.ssh" -i /var/inert/inventory/sshpass.yaml -b -u $user

deployIP=$(yq '.deploy' < /var/inert/settings.yaml )
user=$(yq '.user' < /var/inert/settings.yaml )
pass=$(yq '.pass' < /var/inert/settings.yaml)
echo $pass
if [ "$deployIP" != "null" ]; then
  echo $deployIP deploy >> /etc/hosts
fi

cicdIP=$(yq '.cicd' < /var/inert/settings.yaml )
if [ "$cicdIP" != "null" ]; then
  echo $cicdIP cicd >> /etc/hosts

cat << EOF >> /root/.ssh/config
Host cicd
    USER $user
    StrictHostKeyChecking=no
    IdentityFile ~/.ssh/id_rsa
EOF
fi

k8s=$(yq ".k8s" < /var/inert/settings.yaml)
if [ "$k8s" != "null" ]; then
  k8sc=$(yq e '.k8s | length' < /var/inert/settings.yaml)
  mc=0
  wc=0
  for i in $(seq 1 $k8sc); do
    j=$(($i-1))
    hostname=$(yq ".k8s[$j]" < /var/inert/settings.yaml | cut -d ':' -f1)
    if [ "$hostname" == "master" ]; then
      mc=$(($mc+1))
      ip=$(yq ".k8s[$j]" < /var/inert/settings.yaml | cut -d ' ' -f2)
      echo $ip k8s-m$mc >> /etc/hosts
      sshpass -p $pass ssh-copy-id $user@$ip
    elif [ "$hostname" == "worker" ]; then
      wc=$(($wc+1))
      ip=$(yq ".k8s[$j]" < /var/inert/settings.yaml | cut -d ' ' -f2)
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

haproxy=$(yq ".haproxy" < /var/inert/settings.yaml)
if [ "$haproxy" != "null" ]; then
  hac=$(yq e '.haproxy | length' < /var/inert/settings.yaml)
  for i in $(seq 1 $hac); do
    j=$(($i-1))
    hostname=$(yq ".haproxy[$j]" < /var/inert/settings.yaml | cut -d ':' -f1)
    if [ "$hostname" == "haproxy" ]; then
      ip=$(yq ".haproxy[$j]" < /var/inert/settings.yaml | cut -d ' ' -f2)
      echo $ip ha$i >> /etc/hosts
      sshpass -p $pass ssh-copy-id $user@$ip
    elif [ "$hostname" == "vip" ]; then
      ip=$(yq ".haproxy[$j]" < /var/inert/settings.yaml | cut -d ' ' -f2)
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


nfs=$(yq ".nfs" < /var/inert/settings.yaml)
if [ "$nfs" != "null" ]; then
  nfsc=$(yq e '.haproxy | length' < /var/inert/settings.yaml)
  for i in $(seq 1 $nfsc); do
    j=$(($i-1))
    hostname=$(yq ".nfs[$j]" < /var/inert/settings.yaml | cut -d ':' -f1)
    if [ "$hostname" == "master" ]; then
      ip=$(yq ".nfs[$j]" < /var/inert/settings.yaml | cut -d ' ' -f2)
      echo $ip nfs-m >> /etc/hosts
      sshpass -p $pass ssh-copy-id $user@$ip
    elif [ "$hostname" == "slave" ]; then
      ip=$(yq ".nfs[$j]" < /var/inert/settings.yaml | cut -d ' ' -f2)
      echo $ip nfs-s >> /etc/hosts
      sshpass -p $pass ssh-copy-id $user@$ip
    fi
  done
cat << EOF >> /root/.ssh/config
Host nfs-*
    USER $user
    StrictHostKeyChecking=no
    IdentityFile ~/.ssh/id_rsa
EOF
fi

