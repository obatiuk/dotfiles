#!/usr/bin/env bash

. ../functions

#
# Variables
#

dotfiles_dir=$(pwd)

#
# Setup
#

if ask "Do you want to install font configuration?"; then

    ask "Install required dependencies? (Distro: ${distro})?" Y && bash ./dependencies-${distro}.sh

    # Adding configuration to the current profile

    ln -svfn ${dotfiles_dir}/.bash_profile-fonts ${target_dir}/.bash_profile-fonts

    # Enabling infinality fonts configuration

    sudo bash /etc/fonts/infinality/infctl.sh setstyle infinality

    # Check all required resources

    checkAllResources

fi

