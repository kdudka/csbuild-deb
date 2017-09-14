CSMOCK_VERSION = 2.0.4
CSDIFF_VERSION = 1.3.2
CSWRAP_VERSION = 1.3.4
CSCPPC_VERSION = 1.3.3

UBUNTU_MIRROR = http://archive.ubuntu.com/ubuntu/pool

DEB_RELEASE = 1

DST_REPO = csbuild
UBUNTU_RELEASE ?= trusty
I386_DIR = dists/$(UBUNTU_RELEASE)/contrib/binary-i386
AMD64_DIR = dists/$(UBUNTU_RELEASE)/contrib/binary-amd64

CSBUILD_VERSION = $(CSMOCK_VERSION)
CSBUILD_SRC = csbuild_$(CSBUILD_VERSION).orig
CSBUILD_DEB = csbuild_$(CSBUILD_VERSION)-$(DEB_RELEASE)_amd64.deb

CSBUILD_TGZ = $(CSBUILD_SRC).tar.gz
CSMOCK_TGZ = $(CSBUILD_SRC)-csmock.tar.gz
CSDIFF_TGZ = $(CSBUILD_SRC)-csdiff.tar.gz
CSWRAP_TGZ = $(CSBUILD_SRC)-cswrap.tar.gz
CSCPPC_TGZ = $(CSBUILD_SRC)-cscppc.tar.gz

CSBUILD_DIR = csbuild-$(CSBUILD_VERSION)
CSMOCK_DIR = $(CSBUILD_DIR)/csmock
CSDIFF_DIR = $(CSBUILD_DIR)/csdiff
CSWRAP_DIR = $(CSBUILD_DIR)/cswrap
CSCPPC_DIR = $(CSBUILD_DIR)/cscppc

.PHONY: build pbuild prep repo

build: prep
	cd $(CSBUILD_DIR) && debuild -uc -us

pbuild: build
	pbuilder-dist $(UBUNTU_RELEASE) build --buildresult $(PWD) csbuild_$(CSBUILD_VERSION)-$(DEB_RELEASE).dsc

$(CSBUILD_DEB):
	test -r $@ || $(MAKE) pbuild

repo: $(CSBUILD_DEB)
	mkdir -p $(DST_REPO)/$(I386_DIR) $(DST_REPO)/$(AMD64_DIR)
	ln -fv *amd64.deb $(DST_REPO)/$(AMD64_DIR)
	cd csbuild && dpkg-scanpackages $(I386_DIR) | gzip > $(I386_DIR)/Packages.gz
	cd csbuild && dpkg-scanpackages $(AMD64_DIR) | gzip > $(AMD64_DIR)/Packages.gz

prep: $(CSMOCK_DIR) $(CSDIFF_DIR) $(CSWRAP_DIR) $(CSCPPC_DIR) $(CSBUILD_TGZ)
	cd $(CSBUILD_DIR) && for i in $$(<debian/patches/series); do patch -p1 < debian/patches/$$i || exit $$?; done

$(CSMOCK_DIR): $(CSMOCK_TGZ)
	mkdir $@ && tar -xf $< --strip-components=1 -C $@

$(CSDIFF_DIR): $(CSDIFF_TGZ)
	mkdir $@ && tar -xf $< --strip-components=1 -C $@

$(CSWRAP_DIR): $(CSWRAP_TGZ)
	mkdir $@ && tar -xf $< --strip-components=1 -C $@

$(CSCPPC_DIR): $(CSCPPC_TGZ)
	mkdir $@ && tar -xf $< --strip-components=1 -C $@

$(CSMOCK_TGZ):
	curl -Lo $@ https://github.com/kdudka/csmock/releases/download/csmock-$(CSMOCK_VERSION)/csmock-$(CSMOCK_VERSION).tar.gz

$(CSDIFF_TGZ):
	curl -Lo $@ https://github.com/kdudka/csdiff/releases/download/csdiff-$(CSDIFF_VERSION)/csdiff-$(CSDIFF_VERSION).tar.gz

$(CSWRAP_TGZ):
	curl -Lo $@ https://github.com/kdudka/cswrap/releases/download/cswrap-$(CSWRAP_VERSION)/cswrap-$(CSWRAP_VERSION).tar.gz

$(CSCPPC_TGZ):
	curl -Lo $@ https://github.com/kdudka/cscppc/releases/download/cscppc-$(CSCPPC_VERSION)/cscppc-$(CSCPPC_VERSION).tar.gz

$(CSBUILD_TGZ):
	tar -cT/dev/null | gzip > $@
