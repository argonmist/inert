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
        on drbd1 {
                device /dev/drbd0;
                disk /dev/sdb1;
                address 10.1.23.53:7788;
                meta-disk internal;
        }
        on drbd2 {
                device /dev/drbd0;
                disk /dev/sdb1;
                address 10.1.23.54:7788;
                meta-disk internal;
        }
}
