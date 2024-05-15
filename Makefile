prefix = /usr
VERSION?=0.0.0
SHELL := /bin/bash

all:
	: # do nothing

build:
	dub build

releasebuild:
	source ~/dlang/ldc-1.38.0/activate && \
	dub build --compiler=ldc2 --d-version=Release -b release

install:
	install -D glusterdplus \
                $(DESTDIR)$(prefix)/sbin/glusterdplus
	install -m 700 -D extra/glusterdplus.service \
                $(DESTDIR)/lib/systemd/system/glusterdplus.service
	mkdir -p $(DESTDIR)/var/lib/glusterdplus
	cp -r public $(DESTDIR)/var/lib/glusterdplus/

clean:
	: # do nothing

distclean: clean

uninstall:
	-rm -f $(DESTDIR)$(prefix)/sbin/glusterdplus
	-rm -f $(DESTDIR)/lib/systemd/system/glusterdplus.service

dist:
	rm -rf glusterdplus-$(VERSION)
	mkdir glusterdplus-$(VERSION)
	cp -r glusterdplus public views extra dub.json \
	      dub.selections.json Makefile source glusterdplus-$(VERSION)/
	tar cvzf glusterdplus-$(VERSION).tar.gz glusterdplus-$(VERSION)

deb: debclean
	VERSION=$(VERSION) $(MAKE) dist
	cp -r debian glusterdplus-$(VERSION)/
	cd glusterdplus-$(VERSION) && debmake -y && debuild -eVERSION=$(VERSION)

debclean:
	rm -rf glusterdplus-dbgsym_*
	rm -rf glusterdplus_*

repoclean: debclean
	rm -rf *.tar.gz

.PHONY: all build install clean distclean uninstall dist deb debclean
