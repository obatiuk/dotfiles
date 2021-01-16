#!/bin/sh

#
# Suspend
#
# Source: https://wiki.archlinux.org/index.php/Dell_XPS_15_9570#Suspend
#

grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) mem_sleep_default=deep"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg


# Intel sound

echo "options snd-hda-intel model=dell-headset-multi" | sudo tee /etc/modprobe.d/dell.conf