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

if ask "Do you want to install font configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    #
    # Config folder
    #

    # Target config folders

    [ -d ${config_dir}/.bash_profile.d ] || mkdir -vp ${config_dir}/.bash_profile.d

    # Adding configuration to the current profile

    ln -svfn ${dotfiles_dir}/.home/.bash_profile.d/.bash_profile-fonts ${config_dir}/.bash_profile.d/.bash_profile-fonts

    #
    # Settings
    #

    # Enabling infinality fonts configuration

    sudo bash /etc/fonts/infinality/infctl.sh setstyle infinality

    # Check all required resources

    checkAllResources

fi

