%.qcow2: %.json;
	PACKER_CACHE_DIR="/srv/images/sources" packer build -except=virtualbox-iso $<
	virt-sparsify qemu/packer-qemu.qcow2 qemu/packer-qemu-sparsy.qcow2
	qemu-img convert -O qcow2 qemu/packer-qemu-sparsy.qcow2 /srv/images/$@ -c
	rm -rf qemu
#	tests/runner.sh $@


%.vbox: %.json;
	PACKER_CACHE_DIR="/srv/images/sources" packer build -except=qemu $<
	tar cf $<.tar virtualbox/packer-virtualbox-iso-disk1.vmdk virtualbox/packer-virtualbox-iso.ovf
	mv $<.tar /srv/images
	rm -rf virtualbox


qemu: $(patsubst %.json,%.qcow2,$(wildcard *.json))
vbox: $(patsubst %.json,%.vbox,$(wildcard *.json))

test:
	./tester.sh

all: qemu vbox

