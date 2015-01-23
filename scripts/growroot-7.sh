#!/bin/sh
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
