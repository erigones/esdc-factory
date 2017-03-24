BUILD_TARGETS =	base-centos-6 \
				base-centos-7 \
				base-64-es \
				centos-6 \
				centos-7 \
				esdc-mon \
				esdc-mgmt \
				esdc-cfgdb \
				esdc-dns \
				esdc-img \
				esdc-node \
				contrib-gitlab-ce \
				contrib-centos7-desktop

define newline


endef

comma:= ,
empty:=
space:= ${empty} $(empty)
reverse_clean = $(if $(1),$(call reverse_clean,$(wordlist 2,$(words $(1)),$(1)))) $(if $(1),$(firstword clean-$(1)))
build_targets = $(subst $(space),$(newline)$(space)$(space)$(space)$(space),$(BUILD_TARGETS))
clean_targets = $(call reverse_clean,$(BUILD_TARGETS))

define HELP_TEXT
 **** Danube Cloud   Assembly Line ****

 Please use 'make <target>' where <target> is one of:

  init           initialize the builder directory structure
  check          examine the builder directory structure and HTTP access
  archive-<pkg>  build a tarball for the hypervisor, one of:
    local        /opt/local on the hypervisor
    monitoring   /opt/zabbix on the hypervisor
    esdc-node    /opt/erigones on the hypervior
  archives       download hypervisor OS archives
  isos           download iso images
  platform       download hypervisor platform archive
  usb-deps       download archives, isos and platform
  usb-image      build USB image
  imgapi-tree    rebuild the IMGAPI tree
  clean          delete all appliance VMs and their base images in reverse order
  clean-<app>    delete appliance VM and its base image
  all            build all appliances/images
  base           build all base appliances (base-centos-6 base-centos-7 base-64-es centos-6 centos-7)
  esdc           build all Danube Cloud appliances (esdc-mon, esdc-mgmt, esdc-cfgdb, esdc-dns, esdc-img, esdc-node)
  <app>          build an appliance/image, one of:

    $(build_targets)

    NOTE: The build order is rather important.

 Following environment variables will change the build behaviour:

  VERSION      build a specific version of an appliance (default: current YYYYMMDD)
  VERBOSE      make ansible more verbose
  EXTRA_VARS   override ansible variables, e.g.:
    - usb_type={hn,cn}  (default: hn)
    - release_edition={ce,ee}  (default: ce)
    - esdc_source_repo="https://github.com/erigones/esdc-ce.git"
    - esdc_prod_repo=""
    - image_debug={false,true}  (default: false)

endef

.PHONY: help init check clean imgapi-tree all $(BUILD_TARGETS) $(clean_targets)

help:
	@echo "$(subst $(newline),\n,${HELP_TEXT})"

init:
	@bin/ansible.sh init

check:
	@bin/ansible.sh check

imgapi imgapi-tree:
	@bin/ansible.sh imgapi-tree

archives platform isos:
	@bin/ansible.sh get-$@

usb-deps: archives platform isos

usb usb-image:
	@bin/ansible.sh build-usb-image

$(clean_targets) clean-tmp:
	@bin/ansible.sh $@

clean: $(clean_targets) clean-tmp

$(BUILD_TARGETS):
	@bin/ansible.sh build-$@

all: $(BUILD_TARGETS)

base: base-centos-6 base-centos-7 base-64-es centos-6 centos-7

esdc: esdc-mon esdc-mgmt esdc-cfgdb esdc-dns esdc-img esdc-node

archive-local local-archive:
	@bin/ansible.sh build-archive-local

archive-monitoring monitoring-archive:
	@bin/ansible.sh build-archive-monitoring

archive-esdc-node esdc-node-archive:
	@bin/ansible.sh build-archive-esdc-node
