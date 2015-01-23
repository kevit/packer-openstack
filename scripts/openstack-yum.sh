#!/bin/bash
. /tmp/common.sh
set -x

mv /tmp/cloud.cfg /etc/cloud/cloud.cfg
mv /tmp/firstboot.sh /etc/firstboot.sh
mkdir /var/log/firstboot

echo "/etc/firstboot.sh && sed -i '/firstboot.sh/d' /etc/rc.local" >> /etc/rc.local
chmod 755 /etc/firstboot.sh


# install cloud packages
$yum update
    $yum install cloud-init cloud-utils cloud-utils-growpart git

if [ "$OS" == "centos" ] ; then
    # Change default user to centos and add to wheel
    # Also make it so that we use proper cloud-init
    # configuration.
    sed -ni '/system_info.*/q;p' /etc/cloud/cloud.cfg

fi

$yum erase git

    if [ -e /boot/grub/grub.conf ] ; then
        sed -i -e 's/rhgb.*/console=ttyS0,115200n8 console=tty0 quiet/' /boot/grub/grub.conf
        cd /boot
        ln -s boot .
    elif [ -e /etc/default/grub ] ; then
        sed -i -e \
            's/GRUB_CMDLINE_LINUX=\"\(.*\)/GRUB_CMDLINE_LINUX=\"console=ttyS0,115200n8 console=tty0 quiet \1/g' \
            /etc/default/grub
        grub2-mkconfig -o /boot/grub2/grub.cfg
    fi

# Make sure sudo works properly with openstack
sed -i "s/^.*requiretty$/Defaults !requiretty/" /etc/sudoers

# Make sure no LC_ settings in sshd_file
sed -i /AcceptEnv/d /etc/ssh/sshd_config

