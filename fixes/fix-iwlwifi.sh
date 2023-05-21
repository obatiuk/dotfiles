#!/bin/sh

# Fix for iwlwifi performance drop for "Intel Corporation Centrino Advanced-N 6235 (rev 24)" network controller
#
# Source:
# - https://wireless.wiki.kernel.org/en/users/Drivers/iwlwifi#wifibluetooth_coexistence
# - https://wiki.debian.org/iwlwifi

echo options iwlwifi bt_coex_active=0 swcrypto=1 11n_disable=8 | sudo tee /etc/modprobe.d/iwlwifi.conf
sudo modprobe -rfv iwldvm
sudo modprobe -v iwlwifi
