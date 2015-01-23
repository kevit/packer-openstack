#!/bin/bash

if grep '^GRUB_RECORDFAIL_TIMEOUT=' /etc/default/grub ; then
     echo GOOD: /etc/default/grub
   else
        echo FIXING: /etc/default/grub
        perl -pi.bak -e \
        's/^(GRUB_TIMEOUT=.*\n)/${1}GRUB_RECORDFAIL_TIMEOUT=2\n/' \
        /etc/default/grub
        update-grub
   fi

