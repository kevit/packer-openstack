#!/bin/sh -x
dest="/mnt"

rootdisks=vtbd0
host=build
int=vtnet0
nettype=DHCP

ifconfig="DHCP"
routeropt="#"

gpart destroy -F $rootdisks
gpart create -s MBR $rootdisks
gpart add -t freebsd $rootdisks
gpart create -s bsd ${rootdisks}s1
gpart add -a 4k -t freebsd-ufs ${rootdisks}s1
gpart set -a active -i 1 $rootdisks
gpart bootcode -b /boot/mbr $rootdisks
gpart bootcode -b /boot/boot ${rootdisks}s1
newfs -U -t /dev/${rootdisks}s1a
mount /dev/${rootdisks}s1a /mnt

echo "Installing base system"
cd /usr/freebsd-dist
if test $? -ne 0 ; then
  exit
fi

export DESTDIR=$dest
for file in base.txz kernel.txz ports.txz;
do (cat $file | tar --unlink -xpJf - -C ${DESTDIR:-/}); done

cp -Rlp $dest/boot/GENERIC/* $dest/boot/kernel
#cp -Rlp $dest/boot/kernel $dest/boot/GENERIC

touch $dest/etc/fstab

cat /tmp/bsdinstall_etc/resolv.conf > $dest/etc/resolv.conf

cat <<EOF >$dest/boot/loader.conf
virtio_load="YES"
virtio_blk_load="YES"
virtio_pci_load="YES"
virtio_balloon_load="YES"
if_vtnet_load="YES"
EOF

echo "Configuring /etc/rc.conf"
cat <<EOF >$dest/etc/rc.conf
# Network Settings
hostname="$host"
${routeropt}defaultrouter="$router"
ifconfig_$int="$ifconfig"

# Console Settings
keymap="us.iso"
keyrate="fast"

# Services
pf_enable="YES"
pf_rules="/etc/pf.conf"
sshd_enable="YES"
ntpdate_enable="YES"
ntpd_enable="YES"
local_enable="YES"
EOF


cat <<EOF >$dest/etc/ntp.conf
server 0.uk.pool.ntp.org
server 1.uk.pool.ntp.org
server 2.uk.pool.ntp.org
server 3.uk.pool.ntp.org

driftfile /var/db/ntpd.drift
restrict default ignore
EOF


cat <<EOF > $dest/etc/fstab
# Device        Mountpoint    FStype    Options    Dump    Pass#
/dev/vtbd0s1a    /              ufs        rw        1        1

EOF

tzsetup -C $dest UTC

touch $dest/etc/pf.conf

#$dest/usr/sbin/pkg -c $dest update -q -f

chroot /mnt /bin/sh -c 'echo packer | pw usermod root -h0'

echo "Now completed"

chroot /mnt /bin/sh -c "sed -i -e 's/#PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config"
chroot /mnt /bin/sh -c "sed -i -e 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config"

echo /etc/base.sh >> $dest/etc/rc.local
