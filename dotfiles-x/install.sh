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

if ask "Do you want to install 'X' configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    #
    # Configuration files
    #

    stow --dir=packages --target=${HOME} -vv --stow --no-folding dotfiles-x

    #
    # Settings
    #

    # Git config

    git config --global credential.helper gnome-keyring

    if ask "Enable Graphic Mode?"; then
	sudo systemctl set-default graphical.target
    fi

    if ask "Enable GDM?"; then
	sudo systemctl enable gdm
    fi

    if ask "Start X?"; then
		sudo systemctl isolate graphical.target
    fi

    # Check all required resources

    checkAllResources

fi
