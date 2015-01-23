#!/bin/bash
. /tmp/common.sh
set -x

# Remove isc-dhcp-client as it does not owrk properly with this right now,
# it will be replaced with pump for the time being
$apt update
$apt remove isc-dhcp-client
$apt install cloud-utils cloud-init bash-completion cloud-initramfs-growroot
echo "deb http://http.debian.net/debian wheezy main" > /etc/apt/sources.list
echo "deb http://http.debian.net/debian wheezy-updates main" >> /etc/apt/sources.list
echo "deb http://security.debian.org/ wheezy/updates main" >> /etc/apt/sources.list
$apt update
$apt install pump

# use our specific config
mv -f /tmp/cloud.cfg /etc/cloud/cloud.cfg
rm -f /etc/cloud/cloud.cfg.d/90_*

$apt install sudo rsync curl less

# change GRUB so log tab and console tab in openstack work
if [ -e /etc/default/grub ] ; then
    sed -i -e 's/quiet/console=ttyS0,115200n8 console=tty0 quiet/' \
        /etc/default/grub
    update-grub
fi

# Remove reference to a specific device. This breaks on openstack.
if [ -e /etc/yaboot.conf ] ; then
    sed -i -e 's/^device\(.*\)/#device\1/g' /etc/yaboot.conf
fi

# Make sure sudo works properly with openstack and vagrant
sed -i 's/env_reset/env_reset\nDefaults\t\!requiretty/' /etc/sudoers

# Fix networking to auto bring up eth0 and work correctly with cloud-init
sed -i 's/allow-hotplug eth0/auto eth0/' /etc/network/interfaces

#$apt autoremove
#$apt autoclean

mv /tmp/cloud.cfg /etc/cloud/cloud.cfg
mv /tmp/firstboot.sh /etc/firstboot.sh

sed -i '/exit 0/d' /etc/rc.local
echo "/etc/firstboot.sh && sed -i '/firstboot.sh/d' /etc/rc.local" >> /etc/rc.local
chmod 755 /etc/firstboot.sh
$apt clean
mkdir /var/log/firstboot
mkdir /home/cloud-user/.ssh; chown cloud-user /home/cloud-user/.ssh

rm -f /root/shutdown.sh
