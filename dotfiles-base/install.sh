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

if ask "Do you want to install base configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    #
    # Configuration files
    #

    stow --dir=packages --target=${HOME} -vv --stow dotfiles-base

    #
    # Settings
    #

    # Git config

    git config --global credential.helper gnome-keyring

    # Check all required resources

    checkAllResources

    if ask "Enable GDM?"; then
	sudo systemctl enable gdm
    fi
    
    if ask "Generate default global .gitconfig?"; then
	git config --global color.ui auto
	git config --global core.autocrlf input
	git config --global push.default simple
	git config --global credential.helper gnome-keyring
    fi
fi
