# DELL XPS 15 7590 model patches

# TODO: add command-configure utility

.PHONY:
grubby:
	@sudo dnf -y install grubby

# Fix known suspend issues
.PHONY:
fix_dell_deep_sleep: grubby
	@sudo grubby --args='mem_sleep_default=deep' --update-kernel=ALL

# Remove redness from video stream
.PHONY:
fix_dell_camera:
	@sudo dnf install v4l-utils
	@v4l2-ctl -c saturation=42

.PHONY:
install_nvidia_drivers: | /etc/yum.repos.d/rpmfusion-nonfree.repo akmods grubby
	@sudo dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda vulkan nvidia-vaapi-driver libva-utils vdpauinfo
	@sudo grubby --update-kernel=ALL --args='rd.driver.blacklist=nouveau modprobe.blacklist=nouveau'
	@sudo akmods --force
	@sudo dracut --force

# Headphones are not automatically recognized by the system
.PHONY:
/etc/modprobe.d/dell.conf:
	@sudo tee $@ <<- EOF
		#
		# Created manually on $$(date -I) by ${USER}
		#
		# https://bbs.archlinux.org/viewtopic.php?id=222322
		#
		options snd-hda-intel model=dell-headset-multi
	EOF

# Disable bluetooth auto-suspend
.PHONY:
/etc/modprobe.d/btusb.conf:
	@sudo tee $@ <<- EOF
		#
		# Created manually on $$(date -I) by ${USER}
		#
		# https://bbs.archlinux.org/viewtopic.php?id=222322
		#
		options btusb enable_autosuspend=0
	EOF

.PHONY:
/etc/sysctl.d/97-swappiness.conf:
	# Source:
	# - http://www.akitaonrails.com/2017/01/17/optimizing-linux-for-slow-computers
	# - https://help.ubuntu.com/community/SwapFaq
	# - https://wiki.archlinux.org/index.php/Solid_State_Drives
	@sudo tee $@ <<- EOF
		#
		# Created manually on $$(date -I) by ${USER}
		#
		vm.swappiness=10
		vm.vfs_cache_pressure=50
	EOF

PATCH += patch_dell_xps
patch_dell_xps: | fix_dell_deep_sleep fix_dell_camera install_nvidia_drivers \
	/etc/modprobe.d/dell.conf /etc/modprobe.d/btusb.conf /etc/sysctl.d/97-swappiness.conf
