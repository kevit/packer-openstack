#!/bin/sh
set -x

if [ -d /var/log/firstboot ] ; then
  # Get user pub key from metadata server
  mkdir -p /root/.ssh
  mkdir -p /home/cloud-user/.ssh; chown cloud-user /home/cloud-user/.ssh
  curl -m 10 -s http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key | grep 'ssh-rsa' >> /home/cloud-user/.ssh/authorized_keys
  echo "AUTHORIZED_KEYS:"
  echo "************************"
  cat /root/.ssh/authorized_keys
  echo "************************"
  
  # Set hostname as given by the metadata server
  curl -m 10 http://169.254.169.254/latest/meta-data/public-hostname | grep novalocal > /etc/hostname
  hostname -F /etc/hostname

#fix .novalocal resolving bug
echo "127.0.0.1 `cat /etc/hostname`" >> /etc/hosts
#fix INSERVERS-251 undefined hostname bug
sed -i s/vagrant/undefined/g /etc/hosts
hostname -F /etc/hosts

#fix INSERVERS-294 banner
sed -i -e 's/PermitRootLogin without-password/PermitRootLogin no\n/g' /etc/ssh/sshd_config
echo 'Please use login as the user "cloud-user" rather than the user "root"' > /etc/banner
echo 'Match User root' >> /etc/ssh/sshd_config
echo 'Banner /etc/banner' >> /etc/ssh/sshd_config

  # Regenerate host ssh key

  if [ -f /etc/debian_version ]; then
    ssh-keygen -A
    /etc/init.d/ssh restart
#fix for locales
touch /var/lib/cloud/instance/locale-check.skip

  elif [ -f /etc/redhat-release ]; then
    rm -rf /etc/ssh/ssh_host*
    sed -i -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
    /etc/init.d/sshd restart
  fi

  # Remove the firstboot marker
  rm -rf /var/log/firstboot
fi

