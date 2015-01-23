#!/bin/bash
apt-get --yes --force-yes remove linux-image-3.11.0-15-generic
apt-get --yes --force-yes remove linux-image-3.11.0-23-generic
apt-get update
apt-get --yes --force-yes install linux-image-generic

#while true; do echo 'Hit CTRL+C'; sleep 1; done

if grep '^GRUB_RECORDFAIL_TIMEOUT=' /etc/default/grub ; then
     echo GOOD: /etc/default/grub
   else
        echo FIXING: /etc/default/grub
        perl -pi.bak -e \
        's/^(GRUB_TIMEOUT=.*\n)/${1}GRUB_RECORDFAIL_TIMEOUT=2\n/' \
        /etc/default/grub
        update-grub
   fi
update-grub

