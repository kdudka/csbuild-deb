CSMOCK_VERSION = 1.6.1
CSDIFF_VERSION = 1.1.3
CSWRAP_VERSION = 1.2.0
CSCPPC_VERSION = 1.2.0

DST_REPO = csbuild
I386_DIR = dists/precise/contrib/binary-i386
AMD64_DIR = dists/precise/contrib/binary-amd64

CSBUILD_VERSION = $(CSMOCK_VERSION)
CSBUILD_SRC = csbuild_$(CSBUILD_VERSION).orig
CSBUILD_DEB = csbuild_$(CSBUILD_VERSION)-1_amd64.deb

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
	pbuilder-dist precise build --buildresult $(PWD) csbuild_$(CSBUILD_VERSION)-1.dsc

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
	curl -o $@ https://git.fedorahosted.org/cgit/csmock.git/snapshot/csmock-$(CSMOCK_VERSION).tar.gz

$(CSDIFF_TGZ):
	curl -o $@ https://git.fedorahosted.org/cgit/codescan-diff.git/snapshot/csdiff-$(CSDIFF_VERSION).tar.gz

$(CSWRAP_TGZ):
	curl -o $@ https://git.fedorahosted.org/cgit/cswrap.git/snapshot/cswrap-$(CSWRAP_VERSION).tar.gz

$(CSCPPC_TGZ):
	curl -o $@ https://git.fedorahosted.org/cgit/cscppc.git/snapshot/cscppc-$(CSCPPC_VERSION).tar.gz

$(CSBUILD_TGZ):
	tar -cT/dev/null | gzip > $@