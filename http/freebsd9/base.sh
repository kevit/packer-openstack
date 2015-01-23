#!/bin/sh -x

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf <<EOT
WITHOUT_X11="YES"
EOT

# Setup SSH for pub key access
sed -i -e 's/\#Pub/Pub/g' /etc/ssh/sshd_config

# A lot of this script was lifted directly from:
# https://github.com/jedi4ever/veewee/tree/master/templates/freebsd-9.1-RELEASE-amd64
# with only a few minor changes.

# allow freebsd-update to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update > /tmp/freebsd-update
chmod +x /tmp/freebsd-update

# update FreeBSD
PAGER=/bin/cat /tmp/freebsd-update fetch
PAGER=/bin/cat /tmp/freebsd-update install

sed -i '' -e '/^REFUSE /d' /etc/portsnap.conf
sed -i '' -e '/^WITHOUT_X11/d' /etc/make.conf

pkg_add -r portupgrade
/usr/local/sbin/portsclean -C

rm -fv /var/db/dhclient.leases.*

freebsd_major=`uname -r | awk -F. '{ print $1 }'`

if [ $freebsd_major -gt 9 ]; then
  # Use pkgng
  env ASSUME_ALWAYS_YES=true pkg bootstrap
  pkg update
  pkg install -y sudo
  pkg install -y curl
  pkg install -y ca_root_nss
  pkg install -y bash
else
  # Use old pkg
  pkg_add -r sudo curl ca_root_nss bash
fi

ln -sf /usr/local/share/certs/ca-root-nss.crt /etc/ssl/cert.pem
chfn -s /usr/local/bin/bash
