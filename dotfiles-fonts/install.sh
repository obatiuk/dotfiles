#!/usr/bin/env bash

[ -n "$(echo $@ | grep "\-debug")" ] && set -x

#
# Variables
#

dotfiles_dir=$(dirname $(readlink -f $0))

#
# Imports
#

. ${dotfiles_dir}/../functions

#
# Setup
#

if ask "Do you want to install 'fonts' configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh


    if [ "$release" -le 25 ]; then

	#
	# Configuration files
	#

	stow --dir=packages --target=${HOME} -vv --stow --no-folding dotfiles-fonts-infinality

	#
	# Settings
	#

	# Enabling infinality fonts configuration

	sudo bash /etc/fonts/infinality/infctl.sh setstyle infinality
    fi

    # Check all required resources

    checkAllResources

fi

