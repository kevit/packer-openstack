#!/bin/bash
set -x
# cloud-init is not able to expand the partition to match the new vdisk size, we need to work around it from the initramfs, before the filesystem gets mounted
# to accomplish this we need to generate a custom initrd
cat << EOF > 05-extend-rootpart.sh
#!/bin/sh

/bin/echo
/bin/echo RESIZING THE PARTITION

/bin/echo "d
n
p
1
2048

w
" | /sbin/fdisk -c -u /dev/vda 
/sbin/e2fsck -f /dev/vda1
/sbin/resize2fs /dev/vda1
EOF

chmod +x 05-extend-rootpart.sh

dracut --force --include 05-extend-rootpart.sh /mount --install 'echo fdisk e2fsck resize2fs' /boot/"initramfs-extend_rootpart-$(ls /boot/|grep initramfs|sed s/initramfs-//g)" $(ls /boot/|grep vmlinuz|sed s/vmlinuz-//g)
rm -f 05-extend-rootpart.sh

tail -4 /boot/grub/grub.conf | sed s/initramfs/initramfs-extend_rootpart/g| sed s/CentOS/ResizePartition/g | sed s/crashkernel=auto/crashkernel=0@0/g >> /boot/grub/grub.conf

sed -i -e 's/default=0/default=1/g' /boot/grub/grub.conf
