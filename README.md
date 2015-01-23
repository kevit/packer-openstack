packer-openstack
================

Making a openstack and vbox images

Usage
================
* make debian-7.5-amd64.vbox
* make debian-7.5-amd64.qcow2
* make qemu
* make vbox
* make all

Structure
================
#first step:
kickstart/preseed making a full system for packer needs

#second step:
packer change necessary files in a raw image
making a grow root step (growroot.sh)

#third step:
image booting first time (firstboot.sh)


C's:
korjavin/packer-FreeBSD-9.3 
chef/bento
