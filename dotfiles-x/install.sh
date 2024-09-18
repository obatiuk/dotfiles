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

if ask "Do you want to apply 'X' configuration?"; then

	bash "./dependencies-${distro}@${release}.sh"

	#
	# Configuration files
	#

	stow --dir=packages --target="${HOME}" -vv --stow --no-folding dotfiles-x

	#
	# Settings
	#

	# Git config

	git config --global credential.helper gnome-keyring

	if ask "Enable Graphic Mode?" Y; then
		sudo systemctl set-default graphical.target
	fi

	if ask "Start Graphic Mode?" Y; then
		sudo systemctl isolate graphical.target
	fi

	# Check all required resources

	checkAllResources

	echo "'X' configuration was successfully applied"
else
	echo "'X' configuration was not applied"
fi
