#!/bin/sh -x
cd /tmp
fetch --no-verify-peer https://raw.github.com/pellaeon/bsd-cloudinit-installer/master/installer.sh
pkg_add py27-setuptools
easy_install eventlet
easy_install iso8601
echo 'console="comconsole,vidconsole"' >> /boot/loader.conf
echo 'autoboot_delay="5"' >> /boot/loader.conf
chmod +x /tmp/installer.sh
/tmp/installer.sh
