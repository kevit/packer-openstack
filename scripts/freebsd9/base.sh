#!/bin/sh -x

freebsd_major=`uname -r | awk -F. '{ print $1 }'`

if [ $freebsd_major -gt 9 ]; then
  # Use pkgng
  env ASSUME_ALWAYS_YES=true pkg bootstrap
  pkg update
  pkg install -y sudo
  pkg install -y curl
  pkg install -y ca_root_nss
else
  # Use old pkg
  pkg_add -r sudo curl ca_root_nss
fi

ln -sf /usr/local/share/certs/ca-root-nss.crt /etc/ssl/cert.pem
echo '
hw.broken_txfifo=1
#hint.atkbd.0.flags="0x0"
console="comconsole,vidconsole"
#hw.ioapic_enable=0

virtio_load="YES"
virtio_pci_load="YES"
virtio_blk_load="YES"
if_vtnet_load="YES"
virtio_balloon_load="YES"
#machdep.disable_mtrrs=1
usb_load="YES"
ukbd_load="YES"
uhid_load="YES"
ums_load="YES"
umass_load="YES"
aio_load="YES"
vkbd_load="YES"

kern.vty=vt
hw.vga.textmode="1"
hint.p4tcc.0.disabled="1"
hint.acpi_throttle.0.disabled="1"
hint.atkbdc.0.disabled="1"
hint.atkbd.0.disabled="1"


' >> /boot/loader.conf

#pkg install -y emacs-nox11

echo '
powerd_enable="NO"
tmpmfs="YES"

background_dhclient="YES"
ifconfig_vtnet0="DHCP"
ipv6_privacy="YES"
ifconfig_vtnet0_ipv6="inet6 accept_rtadv"
fsck_y_enable="YES"
background_fsck="YES"
update_motd="YES"
ntpd_enable="YES"
ntpd_sync_on_start="YES"
static_routes="cloudinit"
rtsold_enable="YES"
cron_enable="YES"
clear_tmp_enable="YES"
dmesg_enable="YES"
usbd_enable="YES"
' >> /etc/rc.conf
echo "md /tmp mfs rw,noatime,-s512M 0 0" >>/etc/fstab
