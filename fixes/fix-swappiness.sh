#!/usr/bin/env bash

# Fix swappiness and VFS cache pressure for desktop machine
#
# Source:
# - http://www.akitaonrails.com/2017/01/17/optimizing-linux-for-slow-computers
# - https://help.ubuntu.com/community/SwapFaq
# - https://wiki.archlinux.org/index.php/Solid_State_Drives

sudo tee /etc/sysctl.d/97-swappiness.conf <<- EOF
	#
	# Created manually on $(date -I) by ${USER}
	#
	vm.swappiness=1
	vm.vfs_cache_pressure=50
EOF
