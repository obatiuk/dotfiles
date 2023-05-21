#!/bin/sh

sudo dnf install v4l-utils

#
# Suspend
#
# Source: https://wiki.archlinux.org/index.php/Dell_XPS_15_9570#Suspend
#

grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) mem_sleep_default=deep"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Camera settings

# Remove redness from video stream
v4l2-ctl -c saturation=42

# Headphones are not automatically recognized by the system

sudo tee /etc/modprobe.d/dell.conf <<- 'EOF'
	# https://bbs.archlinux.org/viewtopic.php?id=222322
	options snd-hda-intel model=dell-headset-multi
EOF

# Disable bluetooth auto-suspend

sudo tee /etc/modprobe.d/btusb.conf <<- 'EOF'
	# https://bbs.archlinux.org/viewtopic.php?id=222322
	options btusb enable_autosuspend=0
EOF
