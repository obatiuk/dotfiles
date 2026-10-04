# DELL XPS 15 7590 model patches

DF_DELL_MAKEFILE_NAME := $(abspath $(lastword $(MAKEFILE_LIST)))
DF_DELL := $(abspath $(dir $(DF_DELL_MAKEFILE_NAME)))

DF_DELL_FSROOT := $(DF_DELL)/fsroot

PKG_RPM += grubby

########################################################################################################################
#
# Files
#

# Dell Command | Configure tool
FILE += /opt/dell/dcc/cctk
/opt/dell/dcc/cctk: $(DF_DELL)/dist/cc.tar.gz | tar
	@mkdir -p /tmp/cc
	@tar -xf $< -C /tmp/cc
	@sudo rpm -Uvh --force /tmp/cc/*.rpm
	@rm -rf /tmp/cc
	@sudo touch $@

# Headphones are not automatically recognized by the system
FILE += /etc/modprobe.d/dell.conf
/etc/modprobe.d/dell.conf: $(DF_DELL_FSROOT)/etc/modprobe.d/dell.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

# Disable bluetooth auto-suspend
FILE += /etc/modprobe.d/btusb.conf
/etc/modprobe.d/btusb.conf: $(DF_DELL_FSROOT)/etc/modprobe.d/btusb.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

FILE += /etc/sysctl.d/97-swappiness.conf
/etc/sysctl.d/97-swappiness.conf: $(DF_DELL_FSROOT)/etc/sysctl.d/97-swappiness.conf.template | gettext-envsubst
	@envsubst '$$TODAY $$USER' < $< | sudo install -m 644 -D /dev/stdin $@

########################################################################################################################
#
# Patches
#

# Fix known suspend issues
.PHONY: fix-dell-deep-sleep
fix-dell-deep-sleep: grubby
	@sudo grubby --args='mem_sleep_default=deep' --update-kernel=ALL

# Remove redness from video stream
.PHONY: fix-dell-camera
fix-dell-camera:
	@sudo dnf install v4l-utils
	@v4l2-ctl -c saturation=42

.PHONY: install-nvidia-drivers
install-nvidia-drivers: /etc/yum.repos.d/rpmfusion-nonfree.repo akmods grubby
	@sudo dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda vulkan nvidia-vaapi-driver libva-utils vdpauinfo
	@sudo grubby --update-kernel=ALL --args='rd.driver.blacklist=nouveau modprobe.blacklist=nouveau'
	@sudo akmods --force
	@sudo dracut --force

.PHONY: apply-custom-bios-settings
apply-custom-bios-settings: /opt/dell/dcc/cctk
	@sudo $< -i $(DF_DELL)/bios-settings.ini
	@sudo $< BootOrder --ActiveBootList=uefi
	@sudo $< BootOrder --BootListType=uefi --Sequence=hdd.1,hdd.2

PATCH += patch-dell-xps-15-7590
patch-dell-xps-15-7590: fix-dell-deep-sleep \
	fix-dell-camera \
	install-nvidia-drivers \
	apply-custom-bios-settings
