
PWD := $(shell pwd)
PACKAGE = rednet

DISTRO=/home/distro
DISTRO_BASE=$(DISTRO)/centos/6.5
DISTRO_ROOT=$(DISTRO_BASE)/os/x86_64

INSTALL = install
INSTALL_PROGRAM = $(INSTALL) --mode=755
INSTALL_DATA = $(INSTALL) --mode=644
INSTALL_DIR = $(INSTALL) -d --mode=755

EC2=ec2-SOMEIP.us-west-2.compute.amazonaws.com

default: iso

vm: iso
	sudo ./util/create-server.sh

iso: repo kvmrednet.iso

%.iso: kickstart/%.cfg
	rm -f $@
	rm -rf isoroot
	mkdir isoroot
	tar -C $(DISTRO_ROOT) -cf - .discinfo isolinux | tar -C isoroot -xf -
	cp $(DISTRO_ROOT)/RPM-GPG-* isoroot
	cp $(DISTRO_ROOT)/RELEASE-* isoroot
	chmod -R u+w isoroot/isolinux
	cp isolinux/* isoroot/isolinux/
	cp $^ isoroot/ks.cfg
	mkisofs -o $@ -log-file mkisofs.log \
		-eltorito-boot    isolinux/isolinux.bin \
		-eltorito-catalog isolinux/boot.cat  \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		-V 'DialinServer' -R -J -T \
		--graft-points \
		isoroot \
		EFI=$(DISTRO_ROOT)/EFI \
		repodata=$(DISTRO_ROOT)/repodata \
		Packages=$(DISTRO_ROOT)/Packages \
		images=$(DISTRO_ROOT)/images \
		updates=$(DISTRO_BASE)/updates \
		EPEL=$(DISTRO_BASE)/EPEL \
		extras=$(DISTRO_BASE)/extras \
		rednet=repo

repo: rpm
	rm -rf repo
	mkdir -p repo/Packages
	cp rpm/RPMS/*/*.rpm repo/Packages
	cp rpmcache/*.rpm repo/Packages
	createrepo --quiet --unique-md-filenames repo

rpm: build
	rm -rf rpm
	mkdir -p rpm/BUILD rpm/RPMS rpm/BUILDROOT
	rpmbuild --quiet -bb --buildroot=$(PWD)/rpm/BUILDROOT $(PACKAGE).spec

build:
	@echo Nothing to build yet

test:
	ssh $(EC2) rm -rf rednet
	scp -qr ../rednet $(EC2):
	ssh $(EC2) '(cd rednet ; make)'
	: ssh $(EC2) sudo rpm -U rednet/rpm/RPMS/x86_64/*.rpm
	ssh $(EC2) sudo yum update -y rednet/rpm/RPMS/x86_64/*.rpm
	: ssh $(EC2) sudo rednet request 23D3C494-03DA-7B4D-B29E-0A45235715EA

clean:
	$(RM) -rf $(CLEANS)
	$(RM) -rf rpm exports repo isoroot
	$(RM) -rf *.iso
	$(RM) -rf mkisofs.log

distclean: clean

