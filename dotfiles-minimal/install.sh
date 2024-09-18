#!/usr/bin/env bash

# shellcheck disable=SC2143
# shellcheck disable=SC2154

[ -n "$(echo "$@" | grep "\-debug")" ] && set -x

#
# Variables
#

dotfiles_dir=$(dirname "$(readlink -f "$0")")

#
# Imports
#

. "${dotfiles_dir}/../functions"

#
# Setup
#

if ask "Do you want to apply 'minimal' configuration?" N; then

	bash "./dependencies-${distro}@${release}.sh"

	#
	# Stow/Restow configuration files
	#

	stow --dir=packages --target="${HOME}" -vv --stow --no-folding dotfiles-minimal

	#
	# Settings
	#

	# Fix for snap bug: https://bugzilla.redhat.com/show_bug.cgi?id=1546896

	sudo ln -s /usr/libexec/snapd /usr/lib/

	if [ "$release" -ge 29 ]; then
		sudo ln -s /var/lib/snapd/snap /snap
	fi

	# Git

	if ask "Generate default global .gitconfig?" Y; then
		git config --global init.defaultBranch master
		git config --global color.ui auto
		git config --global color.diff never
		git config --global core.autocrlf input
		git config --global push.default simple
		git config --global credential.helper libsecret
		git config --global commit.gpgsign true
		git config --global log.showSignature true
		git config --global pager.diff "ydiff"
		git config --global pager.show "ydiff"
		git config --global pager.log bat
		git config --global diff.gpg.textconv 'gpg --no-tty --decrypt --quiet'
		git config --global blame.gpg.textconv 'gpg --no-tty --decrypt --quiet'

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

	if ask "Apply default plymouth configuration?" Y; then
		sudo plymouth-set-default-theme bgrt -R
		sudo grub2-editenv - set menu_auto_hide=1
		sudo grub2-mkconfig -o /boot/grub2/grub.cfg
	fi

	# Make dnf faster

	if ask "Apply dnf speed improvements?" Y; then

		sudo tee -a /etc/dnf/dnf.conf <<- 'EOF'
			fastestmirror=1
			max_parallel_downloads=10
			deltarpm=true
		EOF

	fi

	# Power management

	if ask "Enable power profile auto switch?" Y; then
		sudo systemctl start power-profiles-daemon
		sudo tee /etc/udev/rules.d/81-ppm.auto.rules <<- EOF
			# Manually created at $(date -I) by ${USER}
			#
			# Custom udev rules to select power-profiles-daemon profile based on power status
			#
			# See: obsidian://advanced-uri?vault=default&uid=6e02b6e7-0113-4067-80c1-ce182b689f39

			SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set performance"
			SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity_level}=="Normal", RUN+="/usr/bin/powerprofilesctl set balanced"
			SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity_level}=="Low", RUN+="/usr/bin/powerprofilesctl set power-saver"

		EOF
		sudo udevadm control --reload-rules && sudo udevadm trigger
	fi

	timedatectl set-local-rtc 0 # Make sure RTC is not in local TZ

	# Check all required resources

	checkAllResources

	echo "'minimal' configuration was successfully applied"
else
	echo "'minimal' configuration was not applied"
fi
