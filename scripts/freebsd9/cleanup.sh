#!/bin/sh -x

sed -i '' '/base/d' /etc/rc.local

echo "sysctl kern.geom.debugflags=16" >> /etc/rc.local
echo "gpart resize -i 1 vtbd0" >> /etc/rc.local
echo "gpart resize -i 1 vtbd0s1" >> /etc/rc.local
echo "true > /dev/vtbd0" >> /etc/rc.local
echo "true > /dev/vtbd0s1" >> /etc/rc.local
echo "true > /dev/vtbd0s1a" >> /etc/rc.local
echo "gpart resize -i 1 vtbd0" >> /etc/rc.local
echo "gpart resize -i 1 vtbd0s1" >> /etc/rc.local
echo "growfs -y /" >> /etc/rc.local

curl -s https://raw.githubusercontent.com/pellaeon/bsd-cloudinit-installer/master/installer.sh | bash
rm -rf /root/bsd-cloudinit-master
mkdir -p /root/bsd-cloudinit-master
fetch --ca-cert=/usr/local/share/certs/ca-root-nss.crt -o - https://github.com/vtolstov/bsd-cloudinit/archive/user_data.tar.gz | tar --strip-components=1 -xzvf - -C '/root/bsd-cloudinit-master'
sed -i '' 's|/root/bsd-cloudinit-master/run.py|/root/bsd-cloudinit-master/cloudinit --config-file /etc/cloud.cfg|g' /etc/rc.local
echo "[DEFAULT]" >/etc/cloud.cfg
echo "username=root" >>/etc/cloud.cfg

sed -i '' '/\/etc\/rc.local.bak/d' /etc/rc.local
echo "rm -rf /root/bsd-cloudinit*" >> /etc/rc.local
echo "echo > /etc/rc.local" >> /etc/rc.local
pip install iso8601 eventlet
cat /etc/rc.local
rm -rf /tmp/*
sync
