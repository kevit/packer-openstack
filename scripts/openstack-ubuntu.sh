#!/bin/bash
. /tmp/common.sh
set -x

tasksel install server
tasksel install cloud-image
tasksel install openssh-server

# use our specific config
mv -f /tmp/cloud.cfg /etc/cloud/cloud.cfg
$apt install sudo rsync curl less
rm -f /root/shutdown.sh

mv /tmp/firstboot.sh /etc/firstboot.sh
sed -i '/exit 0/d' /etc/rc.local
echo "/etc/firstboot.sh && sed -i '/firstboot.sh/d' /etc/rc.local" >> /etc/rc.local
chmod 755 /etc/firstboot.sh
mkdir /var/log/firstboot
