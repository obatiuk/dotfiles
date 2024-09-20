# DELL XPS 15 7590 model patches

# TODO: add Nvidia drivers!

grubby:
	@sudo dnf install grubby

# Fix known suspend issues
fix_dell_deep_sleep: grubby
	@sudo grubby --args="mem_sleep_default=deep" --update-kernel=ALL

# Remove redness from video stream
fix_dell_camera:
	@sudo dnf install v4l-utils
	@v4l2-ctl -c saturation=42

# Headphones are not automatically recognized by the system
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
/etc/modprobe.d/btusb.conf:
	@sudo tee $@ <<- EOF
		#
		# Created manually on $$(date -I) by ${USER}
		#
		# https://bbs.archlinux.org/viewtopic.php?id=222322
		#
		options btusb enable_autosuspend=0
	EOF

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
patch_dell_xps: | fix_dell_deep_sleep fix_dell_camera \
	/etc/modprobe.d/dell.conf /etc/modprobe.d/btusb.conf /etc/sysctl.d/97-swappiness.conf
