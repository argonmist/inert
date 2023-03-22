#!/bin/bash
vars='/var/inert/ansible/group_vars/all.yml'
cat << EOF > /var/inert/conf/r0.res 
resource r0 {
        protocol C;
        startup {
                wfc-timeout  15;
                degr-wfc-timeout 60;
        }
        net {
                cram-hmac-alg sha1;
                shared-secret "secret";
        }
EOF
primaryIP=$(yq ".drbd.primary.ip" < $vars)
primaryHost=$(yq ".drbd.primary.hostname" < $vars)
drbdc=$(yq e '.drbd.secondary.ip | length' < $vars)
disk=$(yq ".drbd.disk.path" < $vars)
disknum=1
cat << EOF >> /var/inert/conf/r0.res
        on $primaryHost {
                device /dev/drbd0;
                disk $disk$disknum;
                address $primaryIP:7788;
                meta-disk internal;
        }
EOF
for i in $(seq 1 $drbdc); do
  j=$(($i-1))
  hostname=$(yq ".drbd.secondary.hostname[$j]" < $vars)
  ip=$(yq ".drbd.secondary.ip[$j]" < $vars)
cat << EOF >> /var/inert/conf/r0.res
        on $hostname {
                device /dev/drbd0;
                disk $disk$disknum;
                address $ip:7788;
                meta-disk internal;
        }
}
EOF
done
