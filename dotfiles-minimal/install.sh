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
	git config --global credential.helper gnome-keyring
    fi

    # Check all required resources

    checkAllResources

fi
