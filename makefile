export VERSION!=date +'%Y%m%d%H%M'
export MAINT="Joe Maintainer <joe@example.com>"
export DEB=myconfig.deb
HERE=$(PWD)

all: help

help:
	@echo "Targets:";\
	echo "	deb		build the Debian package ($(DEB))";\
	echo "	deb-inst	install $(DEB), generating it if necessary";\
	echo "	debian-config	install system configuration for Debian/Ubuntu";\
	echo "	debian-init	initialise new Debian/Ubuntu system";

debian-init: deb-inst debian-config

debian-config:
	sudo cp -RPv --preserve=mode --backup=numbered system/debian/* /

deb: $(DEB)

$(DEB): deb-config deb/DEBIAN/control
	dpkg-deb -b deb $@

deb-config:
	cd deb/DEBIAN; $(MAKE) $(MAKEFLAGS); cd $(HERE)

deb-touch:
	touch deb/DEBIAN/control.in

deb-check: deb
	lintian $(DEB)

deb-inst: deb
	sudo apt-get install ./$(DEB) && sudo apt-get autoremove

clean:
	rm -rf *.deb; cd deb/DEBIAN; $(MAKE) $(MAKEFLAGS) clean;\
	cd $(HERE)

.PHONY: all deb deb-config deb-check deb-inst deb-touch clean
.PHONY: debian-config debian-init
