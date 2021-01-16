#!/usr/bin/env bash

[ -n "$(echo $@ | grep "\-debug")" ] && set -x

#
# Variables
#

dotfiles_dir=$(dirname $(readlink -f $0))
echo $dotfiles_dir

#
# Imports
#

. ${dotfiles_dir}/../functions

#
# Setup
#

if ask "Do you want to install 'minimal' configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    #
    # Configuration files
    #

    stow --dir=packages --target=${HOME} -vv --stow --no-folding dotfiles-minimal

    #
    # Settings
    #

    # Fix for snap bug: https://bugzilla.redhat.com/show_bug.cgi?id=1546896

    sudo ln -s /usr/libexec/snapd /usr/lib/

    if [ "$release" -ge 29 ]; then
	sudo ln -s /var/lib/snapd/snap /snap
    fi

    # Git

    if ask "Generate default global .gitconfig?"; then
	git config --global color.ui auto
	git config --global core.autocrlf input
	git config --global push.default simple
	git config --global credential.helper libsecret
	git config --global commit.gpgsign true
    fi

    # Use random MAC address for every WiFi/Ethernet connection by default: https://fedoramagazine.org/randomize-mac-address-nm/

    sudo tee /etc/NetworkManager/conf.d/00-randomize-mac.conf <<- 'EOF'
    [device]
    wifi.scan-rand-mac-address=yes

    [connection]
    wifi.cloned-mac-address=random
    ethernet.cloned-mac-address=random
    EOF

    # Configure plymouth

    if ask "Apply default Plymouth configuration?"; then
	sudo plymouth-set-default-theme bgrt -R
	sudo grub2-editenv - set menu_auto_hide=1
	sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    fi

    # Power management

    # Source: https://www.reddit.com/r/Fedora/comments/5pueys/how_to_save_power_with_your_laptop_running_fedora/

    if ask "Enable tuned profiles?"; then
	sudo dnf install powertop smartmontools tuned-utils
	sudo powertop2tuned -n -e laptop

	sudo tee /etc/udev/rules.d/powersave.rules <<-'EOF'
	    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/sbin/tuned-adm profile laptop"
	    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/sbin/tuned-adm profile desktop"
	EOF

	sudo systemctl enable tuned
    fi

    # Check all required resources

    checkAllResources

fi
