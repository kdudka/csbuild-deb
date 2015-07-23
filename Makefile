CSMOCK_VERSION = 1.8.3
CSDIFF_VERSION = 1.2.3
CSWRAP_VERSION = 1.3.0
CSCPPC_VERSION = 1.2.0
CPPCHECK_VERSION = 1.67

UBUNTU_MIRROR = http://archive.ubuntu.com/ubuntu/pool

AUTOMAKE_DEB = automake_1.14.1-2ubuntu1_all.deb
AUTOMAKE_DEB_URL = $(UBUNTU_MIRROR)/main/a/automake-1.14/$(AUTOMAKE_DEB)

DEB_RELEASE = 1

DST_REPO = csbuild
I386_DIR = dists/precise/contrib/binary-i386
AMD64_DIR = dists/precise/contrib/binary-amd64

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

CPPCHECK_DIR = cppcheck-$(CPPCHECK_VERSION)
CPPCHECK_TGZ = cppcheck_$(CPPCHECK_VERSION).orig.tar.gz
CPPCHECK_TXZ_DEB = cppcheck_$(CPPCHECK_VERSION)-1.debian.tar.xz

.PHONY: build pbuild prep repo

build: prep
	cd $(CSBUILD_DIR) && debuild -uc -us
	cd $(CPPCHECK_DIR) && debuild -uc -us

pbuild: build
	pbuilder-dist precise build --buildresult $(PWD) csbuild_$(CSBUILD_VERSION)-$(DEB_RELEASE).dsc
	pbuilder-dist precise build --buildresult $(PWD) cppcheck_$(CPPCHECK_VERSION)-1.dsc

$(CSBUILD_DEB):
	test -r $@ || $(MAKE) pbuild

repo: $(CSBUILD_DEB) $(AUTOMAKE_DEB)
	mkdir -p $(DST_REPO)/$(I386_DIR) $(DST_REPO)/$(AMD64_DIR)
	ln -fv *all.deb *amd64.deb $(DST_REPO)/$(AMD64_DIR)
	cd csbuild && dpkg-scanpackages $(I386_DIR) | gzip > $(I386_DIR)/Packages.gz
	cd csbuild && dpkg-scanpackages $(AMD64_DIR) | gzip > $(AMD64_DIR)/Packages.gz

prep: $(CSMOCK_DIR) $(CSDIFF_DIR) $(CSWRAP_DIR) $(CSCPPC_DIR) $(CSBUILD_TGZ) $(CPPCHECK_DIR)
	cd $(CSBUILD_DIR) && for i in $$(<debian/patches/series); do patch -p1 < debian/patches/$$i || exit $$?; done
	sed -e 's/, libtinyxml2-dev//' -i $(CPPCHECK_DIR)/debian/control
	sed -e 's/dh_auto_build -- .*$$/dh_auto_build/' -i $(CPPCHECK_DIR)/debian/rules

$(CSMOCK_DIR): $(CSMOCK_TGZ)
	mkdir $@ && tar -xf $< --strip-components=1 -C $@

$(CSDIFF_DIR): $(CSDIFF_TGZ)
	mkdir $@ && tar -xf $< --strip-components=1 -C $@

$(CSWRAP_DIR): $(CSWRAP_TGZ)
	mkdir $@ && tar -xf $< --strip-components=1 -C $@

$(CSCPPC_DIR): $(CSCPPC_TGZ)
	mkdir $@ && tar -xf $< --strip-components=1 -C $@

$(CPPCHECK_DIR): $(CPPCHECK_TGZ) $(CPPCHECK_TXZ_DEB)
	tar -xf $(CPPCHECK_TGZ)
	tar -xf $(CPPCHECK_TXZ_DEB) -C $@

$(CSMOCK_TGZ):
	curl -o $@ https://git.fedorahosted.org/cgit/csmock.git/snapshot/csmock-$(CSMOCK_VERSION).tar.gz

$(CSDIFF_TGZ):
	curl -o $@ https://git.fedorahosted.org/cgit/codescan-diff.git/snapshot/csdiff-$(CSDIFF_VERSION).tar.gz

$(CSWRAP_TGZ):
	curl -o $@ https://git.fedorahosted.org/cgit/cswrap.git/snapshot/cswrap-$(CSWRAP_VERSION).tar.gz

$(CSCPPC_TGZ):
	curl -o $@ https://git.fedorahosted.org/cgit/cscppc.git/snapshot/cscppc-$(CSCPPC_VERSION).tar.gz

$(CSBUILD_TGZ):
	tar -cT/dev/null | gzip > $@

$(CPPCHECK_TGZ):
	curl -O $(UBUNTU_MIRROR)/universe/c/cppcheck/$@

$(CPPCHECK_TXZ_DEB):
	curl -O $(UBUNTU_MIRROR)/universe/c/cppcheck/$@

$(AUTOMAKE_DEB):
	curl -O $(AUTOMAKE_DEB_URL)
